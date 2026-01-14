#!/bin/bash

sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# sudo snap install zig --classic --beta

wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz
tar -xf zig-linux-x86_64-0.13.0.tar.xz
sudo mv zig-linux-x86_64-0.13.0 /usr/local/bin/zig-dir
sudo ln -s /usr/local/bin/zig-dir/zig /usr/local/bin/zig

# flatpak install flathub org.ziglang.Zig