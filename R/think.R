library(jsonlite)
library(httr)

# BaseHandler class (using R6 for object-oriented programming)
BaseHandler <- R6::R6Class(
    "BaseHandler",
    public = list(
        max_attempts = 3, # Maximum number of retry attempts
        retry_delay = 1, # Delay between retry attempts in seconds

        initialize = function() {
            # Constructor
        },
        make_api_call = function(messages, max_tokens, is_final_answer = FALSE) {
            # Attempt to make an API call with retry logic
            for (attempt in 1:self$max_attempts) {
                tryCatch(
                    {
                        response <- self$make_request(messages, max_tokens)
                        return(self$process_response(response, is_final_answer))
                    },
                    error = function(e) {
                        if (attempt == self$max_attempts) {
                            return(self$error_response(toString(e), is_final_answer))
                        }
                        Sys.sleep(self$retry_delay)
                    }
                )
            }
        },
        make_request = function(messages, max_tokens) {
            # This method should be implemented in a subclass for Ollama
            stop("make_request must be implemented in a subclass")
        },
        process_response = function(response, is_final_answer) {
            # Default response processing (can be overridden by subclasses)
            parsed_response <- fromJSON(response)
            return(list(
                title = if (is_final_answer) "Final Answer" else "Reasoning Step",
                content = parsed_response$response,
                next_action = if (is_final_answer) "final_answer" else "continue"
            ))
        },
        error_response = function(error_msg, is_final_answer) {
            # Generate an error response
            return(list(
                title = "Error",
                content = sprintf(
                    "Failed to generate %s after %d attempts. Error: %s",
                    ifelse(is_final_answer, "final answer", "step"),
                    self$max_attempts,
                    error_msg
                ),
                next_action = ifelse(is_final_answer, "final_answer", "continue")
            ))
        }
    )
)

# OllamaHandler class (subclass of BaseHandler)
OllamaHandler <- R6::R6Class(
    "OllamaHandler",
    inherit = BaseHandler,
    public = list(
        model = "llama3.1",
        temperature = 0.7,
        top_p = 0.9,
        initialize = function(model = "llama3.1", temperature = 0.7, top_p = 0.9) {
            self$model <- model
            self$temperature <- temperature
            self$top_p <- top_p
        },
        make_request = function(messages, max_tokens) {
            # prompt <- paste(sapply(messages, function(m) paste(m$role, m$content, sep = ": ")), collapse = "\n")
            prompt <- paste(
                vapply(messages, function(m) paste(m$role, m$content, sep = ": "), character(1)),
                collapse = "\n"
            )

            warning(prompt)
            data <- list(
                model = self$model,
                prompt = prompt,
                stream = FALSE
            )

            # Add optional parameters if they are set
            if (!is.null(self$temperature)) {
                data$temperature <- self$temperature
            }
            if (!is.null(self$top_p)) {
                data$top_p <- self$top_p
            }
            if (!is.null(max_tokens)) {
                data$num_predict <- max_tokens
            }

            response <- httr::POST("http://localhost:11434/api/generate",
                body = data,
                encode = "json"
            )

            if (httr::status_code(response) != 200) {
                stop("Error in Ollama API call: ", httr::content(response, "text"))
            }

            content <- httr::content(response, "text")
            return(content)
        },
        process_response = function(response, is_final_answer) {
            # Parse the outer JSON structure
            parsed_response <- tryCatch(
                {
                    jsonlite::fromJSON(response)
                },
                error = function(e) {
                    message("Error parsing JSON: ", e$message)
                    return(list(title = NULL, response = response, next_action = NULL))
                }
            )

            # Extract next_action from the parsed response
            next_action <- if (!is.null(parsed_response$next_action)) {
                parsed_response$next_action
            } else if (!is.null(parsed_response$response)) {
                # If next_action is not directly available, try to parse it from the response
                content_json <- tryCatch(
                    jsonlite::fromJSON(parsed_response$response),
                    error = function(e) NULL
                )
                if (!is.null(content_json) && !is.null(content_json$next_action)) {
                    content_json$next_action
                } else {
                    "continue" # Default value if next_action is not found
                }
            } else {
                "continue" # Default value if response is not as expected
            }

            # Return the parsed content
            return(list(
                title = parsed_response$title,
                content = parsed_response$response,
                next_action = next_action
            ))
        }
    )
)

# Function to generate response (similar to the Python version)
generate_response <- function(prompt, api_handler) {
    # Initialize conversation
    messages <- list(
        list(role = "system", content = paste(thinkR::SYSTEM_PROMPT, collapse = "\n")),
        list(role = "user", content = prompt),
        list(role = "assistant", content = "Understood. I will now create a detailed reasoning chain following the given instructions, starting with a thorough problem decomposition.")
    )

    steps <- list()
    step_count <- 1
    total_thinking_time <- 0

    lapply(messages, function(m) message(crayon::bold(enc2utf8(m$role)), ": ",  crayon::silver(enc2utf8(m$content))))

    # Main loop for generating reasoning steps
    repeat {
        start_time <- Sys.time()
        step_data <- api_handler$make_api_call(messages, 300)
        end_time <- Sys.time()
        thinking_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        total_thinking_time <- total_thinking_time + thinking_time

        # Store step information
        steps[[length(steps) + 1]] <- list(
            title = paste("Step", step_count, ":", step_data$title),
            content = step_data$content,
            thinking_time = thinking_time
        )

        # Add assistant's response to conversation
        messages[[length(messages) + 1]] <- list(role = "assistant", content = step_data$content)

        # Safely print the assistant's response
        message(
            crayon::bold("assistant: "),
            crayon::italic(toString(step_data$title)), "\n",
            crayon::silver(toString(step_data$content)), "\n"
        )

        # Check for next_action
        next_action <- tolower(trimws(step_data$next_action))
        message("Next reasoning step: ", next_action)

        if (is.null(step_data$content) || trimws(toString(step_data$content)) == "") {
            message("Warning: Received empty response.")
            step_count <- step_count + 1
            if (step_count > 10) {
                message("Maximum step count reached. Exiting loop.")
                break
            }
            next
        }

        # Break loop if it's the final answer or step count exceeds 10
        if (next_action == "" || next_action == "final_answer" || step_count > 10) {
            break
        }

        step_count <- step_count + 1
    }

    # If we've reached this point, we already have the final answer
    final_data <- step_data

    # Add final answer to steps (if it's not already there)
    if (steps[[length(steps)]]$title != "Final Answer") {
        steps[[length(steps) + 1]] <- list(
            title = "Final Answer",
            content = final_data$content,
            thinking_time = thinking_time
        )
    }

    message("Final answer: ", final_data$content)

    # Return final results
    return(list(steps = steps, total_thinking_time = total_thinking_time))
}


## Usage example
# handler <- OllamaHandler$new()
# result <- generate_response("What is the capital of France?", handler)
# print(result)
