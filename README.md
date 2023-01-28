# Take Your Neovim

This single Dockerfile is intended not only to validate the Neovim configuration without hassle, but also to allow you to try out the community-based Neovim bundlers.

## Usage

### AstroNvim

- [The official web site](https://astronvim.github.io/)
- [GitHub repository](https://github.com/AstroNvim/AstroNvim)

`AstroNvim` is my favorite and main Neovim bundlers.Please follow these steps to use AstroNvim.


1. Create a folder in your directory
1. Go to the folder created
1. Run this commands on your terminal
1. 

`docker build --target astro --tag your.favorite.image.name .`
`docker run --rm --name your.favorite.container.name -it astro nvim .

- If you don't have `Docker` on your own machine or just discourage to use my Dockerfile on your local dev environment, try the `GitHub Codespaces` to know how it works.

