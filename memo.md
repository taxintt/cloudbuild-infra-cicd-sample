バージョン
- https://github.com/open-policy-agent/conftest
- https://cloud.google.com/sdk/docs/install?hl=JA
- https://hub.docker.com/_/golang

```
gcloud artifacts repositories create cloudbuild-cicd-test --repository-format=docker \
--location=asia-northeast1 --description="Cloud build custom build step"

gcloud builds submit --config=ci-image.yaml \
	--substitutions=_REPOSITORY="cloudbuild-cicd-test",_IMAGE="builder" .
```