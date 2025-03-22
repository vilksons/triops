## Wiki Guide
- [Downloads](https://github-wiki-see.page/m/vilksons/triops/wiki/Downloads)
- [Development](https://github-wiki-see.page/m/vilksons/triops/wiki/Development)
- [Licenses](https://github-wiki-see.page/m/vilksons/triops/wiki/Licenses)
- [Compiler Option](https://github-wiki-see.page/m/vilksons/triops/wiki/Compiler-Option)
- [VSCode Tasks](https://github-wiki-see.page/m/vilksons/triops/wik/VSCode-Tasks)
- [Up-To-Date](https://github-wiki-see.page/m/vilksons/triops/wiki/Up-To-Date)
- [PawnCC Installation](https://github-wiki-see.page/m/vilksons/triops/wiki/PawnCC-Installation)
- [Required Packages](https://github-wiki-see.page/m/vilksons/triops/wiki/Required-Packages)
- [Package Manager (TPM)](https://github-wiki-see.page/m/vilksons/triops/wiki/Package-Manager-(TPM))
- [CODE OF CONDUCT](https://github-wiki-see.page/m/vilksons/triops/wiki/CODE-OF-CONDUCT)

**Triops Installation and Usage Guide**

**Introduction**

This guide provides instructions for installing and using Triops, a tool designed to streamline the compilation and management of Pawn scripts.

Always remember for MacOS users to run Linux based SA-MP Server please use [Docker](https://www.docker.com/)

**Prerequisites**

* Ensure you have the `triops` script. If not, download it from:
    * GitHub: [https://github.com/vilksons/triops/tree/main/Scripts](https://github.com/vilksons/triops/tree/main/Scripts)
    * Alternative download via cURL: [https://github.com/vilksons/triops/wiki/Downloads](https://github.com/vilksons/triops/wiki/Downloads)
* Install the required packages listed here: [https://github.com/vilksons/triops/wiki/Required-Packages](https://github.com/vilksons/triops/wiki/Required-Packages)

**Installation**

**Windows/MacOS/Android** ([WSL](https://learn.microsoft.com/en-us/windows/wsl/install)/[Git Bash](https://git-scm.com/downloads)/[MSYS2](https://www.msys2.org/)/[mingw-w64](https://www.mingw-w64.org/)/[Cygwin](https://www.cygwin.com/)/[Babun](https://github.com/babun/babun)/[Termux](https://termux.dev/en/)/[UserLAnd](https://play.google.com/store/apps/details?id=tech.ula&hl=id&pli=1)/[Linux Deploy](https://github.com/meefik/linuxdeploy))

1.  Open WSL distribution, Git Bash, MSYS2 or mingw-w64, Termux or similar.
2.  Make the `workspace` script executable:

    ```bash
    chmod +x workspace
    ```

3.  Run the script:

    ```bash
    bash ./workspace
    ```

**Linux**

1.  Make the `workspace` script executable:

    ```bash
    chmod +x workspace
    ```

2.  Run the script:

    ```bash
    ./workspace
    ```

**Usage**

**1. File Renaming**

* Rename your `*.pwn` files to a project-appropriate format (e.g., `yourmode.io.pwn`). Maintain consistent naming conventions.

**2. Compilation** 

* **Default Compilation:** To compile with default settings, execute:

    ```bash
    compile
    ```

* **Specific File Compilation:** To compile a specific file, use:

    ```bash
    compile yourmode.pwn
    ```

    * This option allows compilation without simultaneous processing of all `*.io.*` files.

* **additional compiler options** Refer to: [Compiler Option](https://github.com/vilksons/triops/wiki/Compiler-Option)

    ```bash
    compile yourmode.pwn opt1 opt2 opt3
    ```

    * This option allows compilation without simultaneous processing of all `*.io.*` files.

**Testing and Compatibility**

* Triops ensures compatibility with the original opsn Code script for SA-MP with the PawnCC implementation done by Triops. For a testing example, see: [vilksons/triops-example-codes](https://github.com/vilksons/triops-example-codes)

**3. Configuration (lang.json)**

* Create or modify the `lang.json` file with the following structure:

    ```json
    {
        "amx_options": [
            "-d2",
            "-Z+"
        ],
        "triops_default_exclude": "pawno/include",
        "triops_allow_exclude":   "includes",
        "package_dir":            "pawno/include",
        "chatbot_token":          "gsk_abcd",
        "chatbot_model":          "qwen-2.5-32b",
        "chatbot_biodata":        ""
    }
    ```

**Configuration Details:**  

| Key                | Description |
|--------------------|------------|
| `amx_options`         | Compiler optimization flags (e.g., `-d0` for debugging). Refer to: [Compiler Option](https://github.com/vilksons/triops/wiki/Compiler-Option) |
| `default_exclude`  | Location of the Pawn compiler (`pawncc`) and include files. |
| `allow_exclude` | Other folder permissions for PawnCC compilation filter |
| `package_dir`         | Directory for package manager (TPM). |
| `package_type`        | Package manager type (`wget`, `pycurl`, `urllib3`, `requests`). |
| `chatbot_token`   | Get keys from: [Groq Console](https://console.groq.com/keys). |
| `chatbot_model`   | Get Model from: [Groq Console](https://console.groq.com/). |
| `chatbot_biodata` | Additional chatbot configuration, **example:** `your is ai pawn, your name is lisa`. |

## Sample '`default_exclude`'
```pwn
// our code - mygamemode.pwn
#include "../includes/someFile.pwn"
/// so, if Undefined, "cannot read ; someFile.pwn"
/// even though "includes" exist. such as:
/*
samp-server/
├── gamemodes/
│   ├── mygamemode.pwn
│   └── ...
│
├── includes/
│   ├── customFile.pwn
│   ├── anotherFile.pwn
│   └── ...
│
└── server.cfg
*/
/* then that is the function of "triops_allow_exclude" the contents of the folder where someFile is called,
 * for example "Includes" for the case above.
 */

/// and, for example cases:

// our code - whereincludes.pwn
#include "whereincludes/someFile.inc"
/*
samp-server/
├── gamemodes/
│   ├── whereincludes/
│   │   └── someFile.inc
│   └── mygamemode.pwn
│
└── server.cfg
*/
/// then just ignore it :) .. it won't be an error because we've thought about it.
```