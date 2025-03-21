import os
import hashlib
import json
import sys

def double_sha256():
    """ Double SHA256 - simple, like blockchain """
    rand_bytes = os.urandom(32)
    hash1 = hashlib.sha256(rand_bytes).digest()
    hash2 = hashlib.sha256(hash1).hexdigest()
    return hash2

SERVER_DOUBLE_SHA256 = double_sha256()
BASH_DOUBLE_SHA256 = double_sha256()

""" Export all double_sha256 to bash """
print(f"export SERVER_DOUBLE_SHA256={SERVER_DOUBLE_SHA256}")
print(f"export BASH_DOUBLE_SHA256={BASH_DOUBLE_SHA256}")

def load_json():
    """ Load json for lang.json """
    try:
        with open('lang.json', 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        sys.exit(1)

data = load_json()

def print_export(key, value):
    print(f"export {key}='{value}'")

print_export("TRIOPS_DEFAULT_INCLUDE", data.get('default_exclude', ''))
print_export("TRIOPS_ALLOW_EXCLUDE", data.get('allow_exclude', ''))
print_export("pacman_DIR", data.get('package_dir', ''))
print_export("pacman_INSTALLER", data.get('package_type', ''))
print_export("CHATBOT_TOKEN", data.get('chatbot_token', ''))
print_export("CHATBOT_MODEL", data.get('chatbot_model', ''))
print_export("CHATBOT_BIODATA", data.get('chatbot_biodata', ''))

amx_opt = data.get('amx_options', [])
print_export("AMX_OPT_F", ' '.join(amx_opt))

def process_package(file):
    """ Load json for pacman.json """
    try:
        with open(file) as f:
            try:
                data = json.load(f)
                packages = data.get('package', [])
                if isinstance(packages, list):
                    for pkg in packages:
                        print(pkg)
                else:
                    print(packages)
            except json.JSONDecodeError:
                f.seek(0)
                in_package_section = False
                for line in f:
                    if '\"package\"' in line:
                        in_package_section = True
                        continue
                    if in_package_section and line.strip() == ']':
                        in_package_section = False
                        continue
                    if in_package_section and line.strip():
                        print(line.split('\"')[1])
    except Exception as e:
        print(f'Error loading JSON for "package": {e}', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    """ Ensure the script runs only when executed directly, not when imported """
    
    if len(sys.argv) != 2:
        """ Exit with no error (0) if the argument count is incorrect """
        sys.exit(0)

    """ Retrieve the filename from command-line arguments """
    file = sys.argv[1]

    """ Process the file using the process_package function """
    process_package(file)
