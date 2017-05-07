#!/bin/sh

jsonq() {
    python -c "import sys,json; obj=json.load(sys.stdin); print($1)"
}

API_KEY=$1

# check new build

echo "checking new release..."

LATEST_BUILD=`curl http://ci.tensorflow.org/view/Nightly/job/nightly-android/lastSuccessfulBuild/api/json`

LATEST_BUILD_ID=$(echo $LATEST_BUILD | jsonq 'obj["id"]')
LAST_BUILD_ID=`cat last_build_id.rec`

echo "last build id is $LAST_BUILD_ID, latest build id is $LATEST_BUILD_ID"

if [ "$LAST_BUILD_ID" -ge "$LATEST_BUILD_ID" ]; then
  echo "no new version found"
  exit 1
fi

VERSION_NAME=1.0.0-nightly-$LATEST_BUILD_ID

echo "find new version $VERSION_NAME, start publishing..."

# prepare new release

echo "creating pom file..."

cat > double-tf-android-$VERSION_NAME.pom <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.github.piasy</groupId>
  <artifactId>double-tf-android</artifactId>
  <version>$VERSION_NAME</version>
  <packaging>aar</packaging>
  <name>double-tf-android</name>
  <url>https://github.com/Piasy/double-tf-android</url>
  <licenses>
    <license>
      <name>The MIT License (MIT)</name>
      <url>http://opensource.org/licenses/MIT</url>
    </license>
  </licenses>
  <developers>
    <developer>
      <id>piasy</id>
      <name>piasy</name>
      <email>xz4215@gmail.com</email>
    </developer>
  </developers>
  <scm>
    <connection>https://github.com/Piasy/double-tf-android.git</connection>
    <developerConnection>https://github.com/Piasy/double-tf-android.git</developerConnection>
    <url>https://github.com/Piasy/double-tf-android</url>
  </scm>
</project>
EOL

echo "downloading aar file..."

wget -O double-tf-android-$VERSION_NAME.aar http://ci.tensorflow.org/view/Nightly/job/nightly-android/$LATEST_BUILD_ID/artifact/out/tensorflow.aar

# create version

echo "creating version $VERSION_NAME..."

POST_BODY="{\"name\":\"$VERSION_NAME\",\"desc\":\"auto release of $VERSION_NAME\"}"

RESULT=`curl --user "piasy:$API_KEY" \
-H "Content-Type: application/json" \
-X POST -d "$POST_BODY" \
https://api.bintray.com/packages/piasy/maven/double-tf-android/versions`

CREATED_NAME=$(echo $RESULT | jsonq 'obj.get("name", "")')

echo "created name: $CREATED_NAME, version name: $VERSION_NAME"

if [ "$CREATED_NAME" != "$VERSION_NAME" ]; then
  echo "create version $VERSION_NAME fail, message: $RESULT"
  exit 1
fi

# upload artifact

echo "uploading pom file of $VERSION_NAME..."

RESULT=`curl --user "piasy:$API_KEY" \
-X PUT -d \
@double-tf-android-$VERSION_NAME.pom \
https://api.bintray.com/content/piasy/maven/double-tf-android/$VERSION_NAME/com/github/piasy/double-tf-android/$VERSION_NAME/double-tf-android-$VERSION_NAME.pom?publish=1`

RESULT_MESSAGE=$(echo $RESULT | jsonq 'obj.get("message", "")')

if [ "$RESULT_MESSAGE" != "success" ]; then
  echo "upload pom fail, message: $RESULT"
  exit 1
fi

echo "uploading aar file of $VERSION_NAME..."

RESULT=`curl --user "piasy:$API_KEY" \
-X PUT -d \
@double-tf-android-$VERSION_NAME.aar \
https://api.bintray.com/content/piasy/maven/double-tf-android/$VERSION_NAME/com/github/piasy/double-tf-android/$VERSION_NAME/double-tf-android-$VERSION_NAME.aar?publish=1`

RESULT_MESSAGE=$(echo $RESULT | jsonq 'obj.get("message", "")')

if [ "$RESULT_MESSAGE" != "success" ]; then
  echo "upload aar fail, message: $RESULT"
  exit 1
fi

echo $LATEST_BUILD_ID > last_build_id.rec

echo "publish release $VERSION_NAME succeed!"
