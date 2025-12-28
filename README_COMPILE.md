# Compile ImmortalWrt for Xiaomi CR660x

## Option 1: Compile on Your Remote Server (Debian 11)

You provided a server with 2GB RAM. We have prepared a script `compile_cr660x.sh` that handles dependency installation, swap creation (crucial for 2GB RAM), and compilation.

### Steps:

1.  **Connect to your server**
    Use SSH to connect to your server:
    ```bash
    ssh root@162.211.183.217
    # Password: tmseMHWJ0427
    ```

2.  **Setup Environment (Screen)**
    It is highly recommended to use `screen` to avoid compilation interruption:
    ```bash
    apt update && apt install -y screen
    screen -S build
    ```

3.  **Run the compilation**
    Copy the content of `compile_cr660x.sh` to the server and run it. The script now handles:
    - Debian 11 sources fix
    - Root user permission fix (`FORCE_UNSAFE_CONFIGURE=1`)
    - 4GB Swap creation (for 2GB RAM stability)

    ```bash
    nano compile.sh
    # Paste content, Ctrl+O, Enter, Ctrl+X
    chmod +x compile.sh
    ./compile.sh
    ```

4.  **Retrieve Firmware**
    After compilation, download the firmware from `immortalwrt/bin/targets/ramips/mt7621/` using SCP or SFTP.

## Option 2: GitHub Actions (Cloud Compilation)

We have also set up a GitHub Actions workflow `.github/workflows/build-openwrt.yml`.
If you push this project to GitHub, you can run the "Build ImmortalWrt" workflow.
You will need to update the `.config` in the workflow or use the SSH debug mode to configure it interactively.
