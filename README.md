# aseprite-docker-build
build aseprite from an ubuntu container
use the intructions.txt to build into your own container.

or
Use the Dockerfile and docker-compose.yml to automate image build.
Copy the two files into a folder and run docker-compose build.
Then run a container from the newly created image e,g. docker run -it image-name
The bin folder is in /root/aseprite/build copy it to your desktop.
e.g docker cp jolly_dirac:root/aseprite/build/bin ~/Desktop/
