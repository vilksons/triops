#!/usr/bin/env python3

# Module for operating system interactions, such as reading files and generating random bytes
import os
# Module for hashing, used to create SHA256 hashes
import hashlib
# Module for working with JSON data, such as reading configuration files
import json
# Module for interacting with the system, such as reading command-line arguments and exiting the script
import sys
# Module for working with regular expressions (regex), used for chatbot_token security validation
import re

def double_sha256():
    """ Double SHA256 - simple, like blockchain """
    # Generate 32 random bytes
    rand_bytes = os.urandom(256)
    
    # Perform the first SHA256 hash on the random bytes
    hash1 = hashlib.sha256(rand_bytes).digest()
    
    # Perform the second SHA256 hash on the result of the first hash and return the hex digest
    hash2 = hashlib.sha256(hash1).hexdigest()
    return hash2

# Generate two random double SHA256 hashes and store them in variables
SERVER_DOUBLE_SHA256 = double_sha256()

# Export the double SHA256 values to the bash environment
print(f"export SERVER_DOUBLE_SHA256={SERVER_DOUBLE_SHA256}")

def __load_json__():
    """ Load json for lang.json """
    try:
        # Attempt to open and load the JSON file
        with open('lang.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        # Print an error message if the JSON file cannot be loaded
        print(f"Error loading JSON: {e}")
        sys.exit(0)

# Load the data from lang.json
data = __load_json__()

def print_export(key, value):
    """ Helper function to print an export statement """
    # Format and print the export statement
    print(f"export {key}='{value}'")

# Get the exclude_paths from the JSON data and generate exclude_flags
exclude_paths = data.get('exclude_paths', [])
exclude_flags = ' '.join(f'-i"{path}"' for path in exclude_paths)

# Export the exclude flags
print_export("DEF_EXCLUDE", exclude_flags)

# Export the include paths and other values from the JSON data
print_export("DEF_INCLUDE", data.get('include_paths', ''))
print_export("TLIGPAC_DIR", data.get('include_dir', ''))
print_export("__SAMP_PLUGIN_DIR", data.get('plugins_dir', ''))
print_export("__SAMP_LOG", data.get('samp_log', ''))
print_export("SERVER_CONF", data.get('server_conf', ''))
print_export("__SAMP_EXEC", data.get('samp_executable', ''))
print_export("__REMCACHE", data.get('remcache_auto', ''))
print_export("__REAL_REPOS", data.get('repository', ''))

# Export the chatbot model value
print_export("CHATBOT_MODEL", data.get('bot_model', ''))
# Export the chatbot biodata value
print_export("CHATBOT_BIODATA", data.get('bot_profile', ''))

# Define a regex pattern to validate the chatbot token
valid_token_regex = re.compile("^[a-zA-Z0-9_-]{1,62}$")

# Get the chatbot token from the JSON data
chatbot_token = data.get('bot_token', '')

# Validate the chatbot token format using the regex pattern
if not valid_token_regex.match(chatbot_token):
    sys.exit(0)

# Export the chatbot token value
print_export("CHATBOT_TOKEN", data.get('bot_token', ''))

# Get the amx_flags and export them
amx_opt = data.get('amx_flags', [])
print_export("AMX_OPT_F", ' '.join(amx_opt))

if __name__ == '__main__':
    """ Ensure the script runs only when executed directly, not when imported """
    
    # Check if the number of command-line arguments is not equal to 2
    if len(sys.argv) != 2:
        """ Exit with no error (0) if the argument count is incorrect """
        sys.exit(0)
