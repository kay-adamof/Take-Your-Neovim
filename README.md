# Take Your Neovim

This single Dockerfile is intended not only to validate the Neovim configuration without hassle, but also to allow you to try out the community-based Neovim bundle.

## Usage

### Astro

`docker build --target astro --tag your.favorite.image.name .`
`docker run --rm --name your.favorite.container.name -it astro nvim .


