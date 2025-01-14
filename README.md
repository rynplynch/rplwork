## What is this Repo?

This repository is the source code for [www.rplwork.com](https://www.rplwork.com)


## What does it do?

The site aims to show off a collection of Ryan Lynch's personal projects, as well as other works he has been involved in.

#### How does it do this?
1. Link to live projects that Ryan currently hosts using their homelab.
2. Host static files that Ryan was involved in the creation of.
3. Host static files that are used as dependencies in the building over their projects.

## Building this project

#### Using Nix Flakes
```
nix run github:rynplynch/rplwork
```

#### Using dotnet
Clone this repository
```
git clone git@github.com:rynplynch/rplwork.git
```
Ensure you have the appropriate dotnet sdk and runtime installed. The current versions are documented inside /pkgs/rplwork_client.nix
```
# from the project root
cd rplwork_client

# build and run the project
dotnet run
```


