**Added built image to DockerHub:** <br>
While building:<br>
`docker build -t test_httpd:1`<br>
Re-tagging the existing local image:<br>
`docker tag test_httpd itsforajob/2048_httpd:1`<br>
Commiting changes:<br>
`docker commit test_httpd itsforajob/2048_httpd:1`<br>
Push image to the repository:<br>
`docker push itsforajob/2048_httpd:1`<br>
