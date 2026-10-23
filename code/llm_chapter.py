"""
Functions for working with SmolLM2 and other language models
"""
import torch


def ask_smol_lm(question, model, tokenizer, max_tokens=50):
    """Ask SmolLM2 a question with better formatting"""
    # Format the prompt with instruction
    prompt = [{"role": "user", "content": question}]
    formatted_prompt = tokenizer.apply_chat_template(prompt, tokenize=False, add_generation_prompt=True)
    # formatted_prompt = question
    inputs = tokenizer(formatted_prompt, return_tensors="pt").to(model.device)
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_tokens,
            temperature=0.7,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id,
            eos_token_id=tokenizer.eos_token_id
        )
    # Decode and clean up the response
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    # Extract just the assistant's response that follows after \nassistant\n
    response = response.split("\nassistant\n")[-1].strip()
    return response


def get_next_word_suggestions(text, model, tokenizer, top_k=5):
    """Generate multiple suggestions for the next word"""
    # Tokenize the input text
    inputs = tokenizer(text, return_tensors="pt").to(model.device)
    with torch.no_grad():
        # Get the model's output logits for the next token
        outputs = model(**inputs)
        # Get logits for the last token position (where next token would be predicted)
        next_token_logits = outputs.logits[0, -1, :]
        
        # Apply temperature for sampling diversity
        temperature = 1.0
        next_token_logits = next_token_logits / temperature
        
        # Normalize over the FULL vocabulary, then take the top k. Applying
        # softmax to the top-k logits instead would renormalize over that subset,
        # so the reported probabilities would sum to one and change with top_k.
        probabilities = torch.softmax(next_token_logits.float(), dim=-1)
        top_k_probs, top_k_indices = torch.topk(probabilities, top_k)

        # Decode the tokens to words
        suggestions = []
        for i in range(top_k):
            token_id = top_k_indices[i].item()
            token_text = tokenizer.decode([token_id])
            probability = top_k_probs[i].item()
            suggestions.append((token_text, probability))
    return suggestions


def generate_text_step_by_step(initial_text, model, tokenizer, num_steps=10, temperature=1.0, sample=False, print_progress=True):
    """
    Generate text by repeatedly applying the model and selecting the most probable next token
    """
    current_text = initial_text
    if print_progress:
        print(f"Starting text: '{current_text}'")
        print("=" * 60)
    
    for step in range(num_steps):
        # Tokenize current text
        inputs = tokenizer(current_text, return_tensors="pt").to(model.device)
        
        with torch.no_grad():
            # Get model predictions
            outputs = model(**inputs)
            # Get logits for the next token (last position)
            next_token_logits = outputs.logits[0, -1, :]

            if sample:
                # .float() is required: multinomial over a float16 probability
                # vector draws near-uniformly on MPS, which turns any sampled
                # continuation into gibberish regardless of temperature.
                probs = torch.softmax(next_token_logits.float() / temperature, dim=-1)
                next_token_id = torch.multinomial(probs, num_samples=1).item()
            else:
                # Find the token with highest probability (greedy selection)
                next_token_id = torch.argmax(next_token_logits).item()

            next_token_text = tokenizer.decode([next_token_id])

            # Get the probability of this token
            probabilities = torch.softmax(next_token_logits.float(), dim=-1)
            token_probability = probabilities[next_token_id].item()
            
            # Add the new token to our text
            current_text += next_token_text

            if print_progress:
                print(f"'{current_text}' (prob: {token_probability:.3f})")
            # Stop if we hit an end token
            if next_token_id == tokenizer.eos_token_id:
                if print_progress:
                    print("         🛑 End token reached!")
                break
    return current_text


def generate_text_with_alternatives(initial_text, model, tokenizer, num_steps=8, show_top_k=3):
    """
    Generate text step by step, showing the top alternatives at each step
    """
    current_text = initial_text
    print(f"Starting text: '{current_text}'")
    print("=" * 70)
    
    for step in range(num_steps):
        # Tokenize current text
        inputs = tokenizer(current_text, return_tensors="pt").to(model.device)
        
        with torch.no_grad():
            # Get model predictions
            outputs = model(**inputs)
            next_token_logits = outputs.logits[0, -1, :]
            
            # Get top-k most likely tokens
            top_k_values, top_k_indices = torch.topk(next_token_logits, show_top_k)
            probabilities = torch.softmax(top_k_values, dim=-1)
            
            print(f"\nStep {step + 1}: Top {show_top_k} candidates:")
            
            # Show all top candidates
            for i in range(show_top_k):
                token_id = top_k_indices[i].item()
                token_text = tokenizer.decode([token_id])
                probability = probabilities[i].item()
                marker = "→" if i == 0 else " "
                print(f"  {marker} '{token_text}' (prob: {probability:.3f})")
            
            # Select the most probable (greedy choice)
            chosen_token_id = top_k_indices[0].item()
            chosen_token_text = tokenizer.decode([chosen_token_id])
            current_text += chosen_token_text
            
            print(f"  ✅ Chose: '{chosen_token_text}'")
            print(f"  Current text: '{current_text}'")
            
            # Stop if we hit an end token
            if chosen_token_id == tokenizer.eos_token_id:
                print("  🛑 End token reached!")
                break
    
    print("=" * 70)
    print(f"Final generated text: '{current_text}'")
    return current_text
