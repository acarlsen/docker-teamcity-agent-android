FROM jetbrains/teamcity-agent

ENV VERSION_BUILD_TOOLS "28.0.3"
ENV VERSION_TARGET_SDK "28"

# Prepare System
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends curl html2text openjdk-8-jdk libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 unzip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Download SDK
# Had to use hardcoded url - corresponds to 28.0.2
ADD https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip /tools.zip
RUN unzip /tools.zip -d /sdk && \
    rm -v /tools.zip

# Configure PATH
ENV ANDROID_HOME "/sdk"
ENV PATH "${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Accept Licenses
RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license

# Install SDK Packages
RUN sdkmanager "platform-tools" --verbose && \
    sdkmanager "platforms;android-${VERSION_TARGET_SDK}" --verbose && \
    sdkmanager "build-tools;${VERSION_BUILD_TOOLS}" --verbose && \
    sdkmanager "extras;android;m2repository" --verbose && \
    sdkmanager "extras;google;m2repository" --verbose && \
    sdkmanager "extras;google;google_play_services" --verbose && \   
    sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" --verbose && \
    sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" --verbose

# Fix for Gradle daemon crash: https://github.com/gradle/gradle/issues/3117
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8