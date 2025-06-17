# Flox Environment Export

This project provides scripts to export a Flox environment and upload the exported data to Azure Storage. It is useful for backing up or sharing reproducible development environments.

## Contents

- `export_env.sh`: Exports a specified Flox environment, packaging relevant files and directories.
- `upload_to_azure_storage.sh`: Uploads the exported environment to an Azure File Share.

## Prerequisites

- [Flox](https://floxdev.com/) installed and configured.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and logged in.
- Access to an Azure Storage Account and File Share.

## Usage

### 1. Export a Flox Environment

```sh
./export_env.sh <env-name>
```

- `<env-name>`: The name of the Flox environment to export.

This will create an `export/` directory containing the exported environment files.

### 2. Upload to Azure Storage

```sh
./upload_to_azure_storage.sh <export_folder> <storage_account> <file_share> [<share_directory>]
```

- `<export_folder>`: Path to the export directory created in the previous step.
- `<storage_account>`: Your Azure Storage Account name.
- `<file_share>`: The Azure File Share name.
- `[<share_directory>]`: (Optional) Directory within the file share to upload to. Defaults to `flox_environment`.

You will be prompted for your Azure Storage Account Key.

## License

See [LICENSE](LICENSE) for details.

## Notes

- Ensure you have the necessary permissions to access the Flox environment and Azure resources.
- The scripts perform basic error checking and will exit if required arguments are missing or if operations fail.