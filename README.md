# PIGPEN

## Git LFS requirements
This repository uses [Git LFS](https://git-lfs.com/) for large Unity assets to keep clone sizes manageable and satisfy CI validation. The `.gitattributes` file already tracks common binary assets such as textures (`.png`, `.jpg`, `.psd`, `.tga`, `.tif`), audio (`.wav`, `.mp3`, `.ogg`, `.aif`), 3D assets (`.fbx`, `.glb`, `.gltf`), videos (`.mp4`, `.mov`), prefabs, and Unity packages.

To enable LFS locally:

1. Install Git LFS for your platform (see the [installation guide](https://github.com/git-lfs/git-lfs#installation)).
2. Run `git lfs install` once per machine to activate the hooks.
3. After cloning, run `git lfs pull` (or `git pull`) to download LFS-managed assets.
4. When adding new binary assets covered by `.gitattributes`, commit them normally—LFS will store the binary contents automatically. If you introduce a new binary type, add it to `.gitattributes` before committing.

CI checks expect binary assets to be tracked by LFS. If a large asset is committed without LFS, push validation will fail until the file is added to LFS and recommitted.
