# double-tf-android

A pure Gradle port of the TensorFlow library for Android! Publish [the nightly build of TensorFlow CI](http://ci.tensorflow.org/view/Nightly/job/nightly-android/). The name of this repo is inspired by [JakeWharton/double-espresso](https://github.com/JakeWharton/double-espresso).

[ ![Download](https://api.bintray.com/packages/piasy/maven/double-tf-android/images/download.svg) ](https://bintray.com/piasy/maven/double-tf-android/_latestVersion)

## Dependency

``` gradle
allprojects {
    repositories {
        maven {
            url  "http://dl.bintray.com/piasy/maven"
        }
    }
}

compile 'com.github.piasy:double-tf-android:1.0.0-nightly-125@aar'
```

## Usage

Please refer to [Piasy/mnist-android-tensorflow](https://github.com/Piasy/mnist-android-tensorflow/tree/double-tf-android/MnistAndroid).
