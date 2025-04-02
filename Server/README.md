## What is this?

These is Server, module of Triops/Workspace.

## How does it work?

This will be called via Triops/Workspace which will later function as an additional module.

## What does not work?

This module will not work without calling `source` bash shell from Triops/Workspace. and if not called then a fatal error will occur when the script/function in the Server does not exist