# Multi-User Text Editor - Distributed Computing Final Project

This project is a multi-user distributed text editor to design and implement a distributed system. The text editor should allow multiple users to create real-time edits to the document. The text editor allows a single document to be distributed across several nodes for editing and viewing.

![GIF of the multi-user text editor](https://i.ibb.co/smgkf9C/multi-user-text-editor.gif)

## Demo Video

[Click here to open](https://drive.google.com/file/d/13hinGg6YV8bP0IruyV6edTkANTsm7YAX/view?usp=sharing)

## View Hosted Client and Server

1. Client hosted through [Firebase Hosting](https://firebase.google.com/products/hosting?gclid=CjwKCAjw5NqVBhAjEiwAeCa97biZkz2as1yZ21Zx3KkH-UUG0use8aQ6Z7wXAvE5gY_i6ZMNP1cYfhoCwDoQAvD_BwE&gclsrc=aw.ds) on the following [link](https://multiusertexteditor.web.app/#/document/7323631e-c01d-4f36-81fb-73c5a3ed0230).
2. Server hosted through [DigitalOcean](https://www.digitalocean.com/) on the following [link](http://etch-da.live/).

## Installation (Compile and Run Code Locally)

1. Go to [Flutter Website](https://docs.flutter.dev/get-started/install) to install Flutter.
2. Then download the project from [Github Link](https://github.com/MostafaHeshamETCH/Multi-User-Distributed-Text-Editor) or get it from the provided .zip folder.
3. Open the folder on VS Code or Android Studio and write the following command to run the client-side.
   ```bash
   flutter run -d chrome
   ```
4. Download and install [Docker](https://www.docker.com/).
5. Run the following command to run the needed [AppWrite](https://appwrite.io/docs/installation) Containers.
   ```bash
   docker run -it --rm \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
   --entrypoint="install" \
   appwrite/appwrite:0.14.2
   ```
6. Or manually using Docker compose
   ```bash
   docker-compose up -d --remove-orphans
   ```
7. Create a new project from the locally hosted dashboard
8. Create two collections
   - delta with attributes delta, userId, and device all as strings.
   - pages with attributes title, content, and owner all as strings.
9. Click open document, and a new document with a unique id will be created for you, share the link with other contributors and enjoy collaborative text editing.

## Built with

1. [AppWrite](https://appwrite.io/) for both MariaDB and real-time database capabilities.
2. [Flutter QuillEditor](https://pub.dev/packages/flutter_quill) as a UI for the text editor.
3. [Riverpod](https://riverpod.dev/) for full state management and local caching.
4. [Routemaster](https://pub.dev/packages/routemaster) for proper routing.

## Contributors

1. Maryam Ahmed Nouh
2. Youssef Sherif Mohamed
3. Mostafa Hesham Abd El Raouf
