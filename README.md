thinkR
================

![](logo.webp)

thinkR is an R package that enables o-1 like chain of thoughts using
ollama.

## Installation

To install ceLLama, use the following command:

``` r
devtools::install_github("eonurk/thinkR")
```

## Usage

#### Step 1: Install Ollama

Download [`Ollama`](https://ollama.com/).

#### Step 2: Choose Your Model

Select your preferred model. For instance, to run the Llama3 model, use
the following terminal command:

``` bash
ollama run llama3.1
```

This initiates a local server, which can be verified by visiting
<http://localhost:11434/>. The page should display “Ollama is running”.

#### Step 3: Think!

> Q: How many ’R’s are in strawberry?

``` r
library(thinkR)

## Usage example
ollama <- OllamaHandler$new(model = "llama3.1")
result <- generate_response("How many 'R's are in strawberry?", ollama)
```

<details>
<summary>
Thinking…
</summary>

    ## Step 1 : Reasoning Step
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## ```
    ## 
    ## Reasoning Step 2: Approach 1 - Manual Counting
    ## 
    ## ```json
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## ```
    ## 
    ## Reasoning Step 3: Approach 2 - Pattern Recognition
    ## 
    ## ```json
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## ```
    ## 
    ## Reasoning Step 4: Alternative Count Method
    ## 
    ## ```json
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors
    ## Time: 26.6743881702423 s
    ## 
    ##  Step 2 : Reasoning Step
    ## Here's the revised response with the next step:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'strawberry' again, I confirm that there are indeed two occurrences of the letter 'R', as initially counted in both the manual and pattern recognition methods.",
    ##   "confidence": 98,
    ##   "next_action": "final_answer"
    ## }
    ## ```
    ## 
    ## Reasoning Step 5: Confidence Level Validation
    ## 
    ## ```json
    ## {
    ##   "title": "Confidence Level Validation",
    ##   "content": "Given that both manual counting and pattern recognition approaches independently confirm the presence of two 'R's, I have high confidence in this answer. This validation step ensures the reliability of my reasoning chain.",
    ##   "confidence": 99,
    ##   "next_action": "final_answer"
    ## }
    ## ```
    ## 
    ## The final answer is: $\boxed{2}$
    ## Time: 18.4936249256134 s
    ## 
    ##  Step 3 : Reasoning Step
    ## Here is the complete JSON response:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors",
    ##   "confidence": 85,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'strawberry' again, I
    ## Time: 28.58318400383 s
    ## 
    ##  Step 4 : Reasoning Step
    ## Here is the complete JSON response:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors",
    ##   "confidence": 85,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'strawberry' again, I
    ## Time: 30.5651700496674 s
    ## 
    ##  Step 5 : Reasoning Step
    ## Here is the complete JSON response:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors",
    ##   "confidence": 85,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'strawberry' again, I
    ## Time: 31.5878710746765 s
    ## 
    ##  Step 6 : Reasoning Step
    ## Here is the complete JSON response:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors",
    ##   "confidence": 85,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'strawberry' again, I
    ## Time: 32.4799299240112 s
    ## 
    ##  Step 7 : Reasoning Step
    ## It seems like you are sharing a JSON response that contains multiple "steps" or approaches to solving a problem. 
    ## 
    ## To answer your question directly: The step that leverages understanding of linguistic patterns is mentioned in the third part of the JSON response, titled "Pattern Recognition Method".
    ## 
    ## Here's the relevant text:
    ## 
    ## "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns."
    ## Time: 17.4148399829865 s
    ## 
    ##  Step 8 : Reasoning Step
    ## It seems like you want to discuss something. What's on your mind? I'm here to listen and help if I can!
    ## Time: 10.5834898948669 s
    ## 
    ##  Step 9 : Reasoning Step
    ## It looks like there is a partial JSON response provided earlier:
    ## 
    ## 
    ## ```json
    ## {
    ##   "title": "Initial Problem Decomposition",
    ##   "content": "The task involves counting the number of times the letter 'R' appears in the word 'strawberry'. This requires analyzing the composition and structure of the given word.",
    ##   "confidence": 95,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Manual Counting Method",
    ##   "content": "I will manually go through each letter in 'strawberry': S-T-R-A-W-B-E-R-R-Y. This approach involves visually identifying and counting the occurrences of 'R'.",
    ##   "confidence": 92,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Pattern Recognition Method",
    ##   "content": "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns.",
    ##   "confidence": 88,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Counting Approach",
    ##   "content": "Considering the possibility that my initial count might be incorrect, I will re-check the word for any potential duplicates or errors",
    ##   "confidence": 85,
    ##   "next_action": "continue"
    ## }
    ## {
    ##   "title": "Alternative Count Method Confirmation",
    ##   "content": "Upon reviewing the word 'straw
    ## Time: 35.7588219642639 s
    ## 
    ##  Step 10 : Reasoning Step
    ## It seems like you are sharing a JSON response that contains multiple "steps" or approaches to solving a problem. 
    ## 
    ## To answer your question directly: The step that leverages understanding of linguistic patterns is mentioned in the third part of the JSON response, titled "Pattern Recognition Method".
    ## 
    ## Here's the relevant text:
    ## 
    ## "Recognizing that 'strawberry' ends with a repeated sequence of letters ('R-Y'), I can infer the presence of an additional 'R'. This step leverages understanding of linguistic patterns."
    ## 
    ## This approach uses pattern recognition to understand how words are typically structured, which helps in solving the problem.
    ## Time: 19.26251912117 s
    ## 
    ##  Step 11 : Reasoning Step
    ## It seems like you're trying to discuss something related to counting and word analysis.
    ## 
    ## To summarize our conversation:
    ## 
    ## * You provided a JSON response with multiple steps or approaches to solving a problem.
    ## * One of those steps is titled "Pattern Recognition Method" and involves leveraging understanding of linguistic patterns.
    ## * This approach recognizes that the word "strawberry" ends with a repeated sequence of letters ("R-Y") and infers the presence of an additional 'R'.
    ## 
    ## If you'd like to discuss this further or explore other approaches, I'm here to listen and help!
    ## Time: 18.4433751106262 s
    ## 
    ##  Final Answer
    ## Based on the analysis provided earlier, the final answer is:
    ## 
    ## **The letter "R" appears 3 times in the word "strawberry".**
    ## 
    ## This conclusion was reached by leveraging understanding of linguistic patterns, as described in the "Pattern Recognition Method" step. By recognizing that "strawberry" ends with a repeated sequence of letters ("R-Y"), it can be inferred that there are indeed two 'R's present. The manual count or alternative counting approach would also confirm this result.
    ## 
    ## Therefore, the final answer is 3!
    ## Time: 19.0463080406189 s

</details>

    ## Total thinking time: 288.89 s

> A: Therefore, the final answer is 3!

<br>

> \[!NOTE\]  
> This output is cherry-picked from llama3.1… because 70b was a lot to
> download for my internet connection.

## Acknowledgments

Cursor is a great tool \<3

### Credits

- [g-1](https://github.com/bklieger-groq/g1)
- [multi-1](https://github.com/tcsenpai/multi1)

## License

This project is licensed under the MIT License
