@echo off
SET OUT="%~dpn1.webp"
cwebp -mt -m 6 -q 80 -progress %1 -o %OUT%