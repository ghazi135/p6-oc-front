### Building and running your application

- **Dockerfile**: serves pre-built Angular assets with nginx.
- **compose.yaml**: runs the published Docker image.

**Setup**

1. Start the container:
   ```bash
   docker compose up
   ```

Your application will be available at `http://localhost:<APP_PORT>` (e.g. http://localhost:80 if `APP_PORT=80`).

### Deploying your application to the cloud

Use the published image:

`vbuyakov/ocr-java-angular-project-6-front:latest`

### References
* [Docker's Node.js guide](https://docs.docker.com/language/nodejs/)
