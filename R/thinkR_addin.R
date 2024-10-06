thinkr_addin <- function() {
    # Load necessary libraries
    library(shiny)
    library(shinyjs)
    library(promises)
    library(future)
    library(rstudioapi)

    # Set up future plan for asynchronous processing
    plan(multisession)

    css_content <- readLines(system.file("www", "thinkr_styles.css", package = "thinkR"))

    ui <- shiny::fluidPage(
        shinyjs::useShinyjs(),
        shiny::tags$head(
            shiny::tags$style(HTML(paste(css_content, collapse = "\n"))),
            shiny::tags$style(HTML("
                body, .shiny-input-container, .message-content {
                    font-family: Arial, sans-serif;
                    font-size: 12px;
                }
                .message {
                    margin-bottom: 10px;
                }
                .message-content h4 {
                    font-size: 14px;
                    margin-bottom: 5px;
                }
                .thinking-time {
                    font-size: 10px;
                    color: #888;
                    margin-top: 5px;
                }
                .loading-indicator {
                    display: inline-block;
                    width: 20px;
                    height: 20px;
                    border: 3px solid rgba(0,0,0,.3);
                    border-radius: 50%;
                    border-top-color: #000;
                    animation: spin 1s ease-in-out infinite;
                }
                @keyframes spin {
                    to { transform: rotate(360deg); }
                }
            "))
        ),
        shiny::tags$style(HTML("
            .loading-dots {
                display: inline-block;
            }
            .loading-dots:after {
                content: '...';
                animation: dots 1.5s steps(4, end) infinite;
            }
            @keyframes dots {
                0%, 33% { content: '.'; }
                34%, 66% { content: '..'; }
                67%, 100% { content: '...'; }
            }
        ")),
        shiny::tags$script(HTML("
            Shiny.addCustomMessageHandler('updateChat', function(message) {
                Shiny.setInputValue('triggerChatUpdate', Math.random());
            });
            Shiny.addCustomMessageHandler('updateStep', function(step) {
                Shiny.setInputValue('updateStep', step);
            });
            Shiny.addCustomMessageHandler('error', function(message) {
                console.error('Error:', message);
            });
        ")),
        shiny::tags$script(HTML("
            $(document).on('keydown', '#user_input', function(e) {
                if (e.keyCode == 13 && !e.shiftKey) {
                    e.preventDefault();
                    $('#submit').click();
                }
            });
        ")),
        shiny::div(
            class = "container-fluid p-0",
            shiny::div(
                class = "row no-gutters",
                shiny::div(
                    class = "col-md-12 main-content",
                    shiny::uiOutput("chat_container", class = "chat-container"),
                    shiny::div(
                        class = "input-area",
                        shiny::div(
                            class = "input-wrapper",
                            shiny::div(
                                class = "input-group",
                                shiny::textAreaInput("user_input", NULL, rows = 1, placeholder = "Ask anything", width = "100%"),
                                shiny::actionButton("submit", "Send", class = "btn btn-primary btn-send")
                            ),
                            shiny::div(id = "loading_indicator", class = "loading-indicator", style = "display: none;")
                        )
                    )
                )
            )
        )
    )

    server <- function(input, output, session) {
        chat_history <- shiny::reactiveVal(list())
        is_processing <- shiny::reactiveVal(FALSE)
        steps <- shiny::reactiveVal(list())

        update_chat_ui <- function() {
            output$chat_container <- shiny::renderUI({
                history <- chat_history()
                if (length(history) == 0) {
                    return(NULL)
                }
                chat_elements <- lapply(history, function(message) {
                    if (is.null(message) || !is.list(message) || is.null(message$role)) {
                        return(NULL)
                    }
                    if (message$role == "user") {
                        shiny::div(
                            class = "message user-message",
                            shiny::div(class = "avatar", "U"),
                            shiny::div(class = "message-content", message$content)
                        )
                    } else if (message$role == "assistant") {
                        if (isTRUE(message$is_loading)) {
                            shiny::div(
                                class = "message assistant-message",
                                shiny::div(class = "avatar", "A"),
                                shiny::div(class = "message-content loading-dots")
                            )
                        } else {
                            shiny::div(
                                class = "message assistant-message",
                                shiny::div(class = "avatar", "A"),
                                shiny::div(
                                    class = "message-content",
                                    shiny::h4(message$title),
                                    shiny::p(message$content),
                                    shiny::p(
                                        class = "thinking-time",
                                        paste("Thinking time:", sprintf("%.2f", message$thinking_time), "seconds")
                                    )
                                )
                            )
                        }
                    } else {
                        return(NULL)
                    }
                })
                chat_elements <- Filter(Negate(is.null), chat_elements)
                shiny::div(chat_elements)
            })
        }

        shiny::observeEvent(input$submit, {
            if (trimws(input$user_input) == "") {
                return()
            }

            shinyjs::disable("submit")

            user_message <- list(role = "user", content = input$user_input)
            chat_history(c(chat_history(), list(user_message)))

            loading_message <- list(role = "assistant", is_loading = TRUE)
            chat_history(c(chat_history(), list(loading_message)))
            update_chat_ui()

            shiny::updateTextAreaInput(session, "user_input", value = "")

            is_processing(TRUE)
            current_input <- input$user_input

            promise <- future_promise({
                ollama <- OllamaHandler$new()
                generate_response_callback(current_input, ollama)
            })

            promise %...>% (function(result_steps) {
                current_history <- chat_history()
                chat_history(current_history[-length(current_history)])

                for (step in result_steps) {
                    current_history <- chat_history()
                    updated_history <- c(current_history, list(list(
                        role = "assistant",
                        title = step$title,
                        content = step$content,
                        thinking_time = step$thinking_time,
                        is_final = step$title == "Final Answer"
                    )))
                    chat_history(updated_history)
                    Sys.sleep(0.1)
                }
                is_processing(FALSE)
                shinyjs::enable("submit")
            }) %...!% (function(error) {
                shiny::showNotification(paste("Error:", error$message), type = "error")
                is_processing(FALSE)
                shinyjs::enable("submit")
            })

            shiny::observe({
                if (is_processing()) {
                    shiny::invalidateLater(3000)
                    update_chat_ui()
                }
            })
        })

        shiny::observe({
            shiny::req(input$triggerChatUpdate)
            current_steps <- steps()
            if (length(current_steps) > 0) {
                latest_step <- current_steps[[length(current_steps)]]
                current_history <- chat_history()
                updated_history <- c(current_history, list(list(
                    role = "assistant",
                    title = latest_step$title,
                    content = latest_step$content,
                    thinking_time = latest_step$thinking_time,
                    is_final = latest_step$title == "Final Answer"
                )))
                chat_history(updated_history)
                update_chat_ui()
            }
        })

        shiny::observe({
            if (!is_processing()) {
                shinyjs::enable("submit")
                shinyjs::hide("loading_indicator")
            }
        })
    }

    viewer <- function(url) {
        rstudioapi::viewer(url)
    }

    shiny::runGadget(
        shinyApp(ui = ui, server = server),
        viewer = viewer,
        stopOnCancel = TRUE
    )
}

generate_response_callback <- function(prompt, api_handler) {
    messages <- list(
        list(role = "system", content = paste(thinkR::SYSTEM_PROMPT, collapse = "\n")),
        list(role = "user", content = prompt),
        list(role = "assistant", content = "Understood. I will now create a detailed reasoning chain following the given instructions, starting with a thorough problem decomposition.")
    )

    steps <- list()
    step_count <- 1
    total_thinking_time <- 0

    repeat {
        start_time <- Sys.time()
        tryCatch(
            {
                step_data <- api_handler$make_api_call(messages, 300)
            },
            error = function(e) {
                stop(e)
            }
        )
        end_time <- Sys.time()
        thinking_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
        total_thinking_time <- total_thinking_time + thinking_time

        current_step <- list(
            title = paste("Step", step_count, ":", step_data$title),
            content = step_data$content,
            thinking_time = thinking_time
        )
        steps[[length(steps) + 1]] <- current_step

        next_action <- tolower(trimws(step_data$next_action))

        if (is.null(step_data$content) || trimws(toString(step_data$content)) == "") {
            step_count <- step_count + 1
            next
        }

        if (step_count > 25 || next_action == "final_answer") {
            break
        }

        step_count <- step_count + 1
    }

    final_data <- step_data

    if (steps[[length(steps)]]$title != "Final Answer") {
        final_step <- list(
            title = "Final Answer",
            content = final_data$content,
            thinking_time = thinking_time
        )
        steps[[length(steps) + 1]] <- final_step
    }

    return(steps)
}
