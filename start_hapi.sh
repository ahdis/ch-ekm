cp ./output/package.tgz hapifhir
docker run -p 8080:8080 -v $(pwd)/hapifhir:/configs -e "--spring.config.additional-location=file:///configs/application.yaml" hapiproject/hapi:latest
