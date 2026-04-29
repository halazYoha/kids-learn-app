import os
import re

def strip_gradient_decoration(content):
    # This tries to match `decoration: BoxDecoration(`
    # and then uses simple bracket counting to find the closing parenthesis.
    out = []
    i = 0
    while i < len(content):
        # Look for the start
        if content[i:].startswith("decoration: BoxDecoration("):
            # Check if this decoration actually contains a gradient
            # Just doing a fast-forward peek
            peek = content[i:i+500]
            if "gradient: LinearGradient" in peek or "gradient:" in peek:
                # Need to parse and skip the whole decoration block
                start_idx = i
                i += len("decoration: BoxDecoration")
                # Now we look for matching brackets starting from the `(`
                bracket_count = 0
                found_open = False
                while i < len(content):
                    if content[i] == '(':
                        bracket_count += 1
                        found_open = True
                    elif content[i] == ')':
                        bracket_count -= 1
                    
                    i += 1
                    if found_open and bracket_count == 0:
                        # Found the end of BoxDecoration!
                        # Optionally skip a trailing comma and whitespace
                        while i < len(content) and content[i] in [' ', '\n', '\r', '\t', ',']:
                            i += 1
                        break
                continue # don't append anything from the block
        
        out.append(content[i])
        i += 1
    
    return "".join(out)

def strip_glass_cards(content):
    # HomeScreen and CategoryHubScreen and StoryScreen
    # Replace ClipRRect + BackdropFilter with standard Card or Container
    # We will just do a direct regex replace for the specific setups
    pass

def process_dir(directory):
    for root, _, files in os.walk(directory):
        for f in files:
            if f.endswith(".dart"):
                path = os.path.join(root, f)
                with open(path, "r") as file:
                    content = file.read()
                
                # Strip gradient
                if "LinearGradient" in content and "decoration: BoxDecoration(" in content:
                    new_content = strip_gradient_decoration(content)
                    if new_content != content:
                        with open(path, "w") as file:
                            file.write(new_content)
                        print(f"Refactored gradients in: {path}")

if __name__ == "__main__":
    process_dir("/home/halaz/kids-learn2/kids_app/lib")
