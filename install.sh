#!/bin/bash

cd ~/Downloads && curl -l -o workspace https://raw.githubusercontent.com/vilksons/triops/refs/heads/main/Scripts/workspace && \
        chmod +x workspace && bash ./workspace