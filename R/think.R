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
            prompt <- paste(sapply(messages, function(m) paste(m$role, m$content, sep = ": ")), collapse = "\n")

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
                encode = "json",
                httr::write_memory()
            )

            if (httr::status_code(response) != 200) {
                stop("Error in Ollama API call: ", httr::content(response, "text"))
            }

            content <- httr::content(response, "text")
            return(content)
        },
        process_response = function(response, is_final_answer) {
            # Parse the outer JSON structure
            parsed_text <- tryCatch(
                {
                    jsonlite::fromJSON(response)
                },
                error = function(e) {
                    message("Error parsing JSON: ", e$message)
                    return(list(title = NULL, response = response, next_action = NULL))
                }
            )

            # Return the parsed content
            return(list(
                title = parsed_text$title,
                content = parsed_text$response,
                next_action = parsed_text$next_action
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

    lapply(messages, function(m) message(enc2utf8(m$role), ": ", enc2utf8(m$content)))
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
            "\nAssistant: ",
            crayon::bold(step_data$title), "\n",
            crayon::blue(toString(step_data$content)), "\n"
        )

        # Check for next_action
        next_action <- tolower(trimws(step_data$next_action))
        cat("Next reasoning step: ", next_action, "\n")

        # Check if the content is empty or only whitespace
        if (is.null(step_data$content) || trimws(toString(step_data$content)) == "") {
            message("Warning: Received empty response. Retrying...")
            next # Skip to the next iteration of the loop
        }

        # Break loop if it's the final answer or step count exceeds 10
        if (next_action == "final_answer" || step_count > 10) {
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
