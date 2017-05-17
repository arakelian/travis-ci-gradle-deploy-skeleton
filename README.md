# How to deploy Gradle project to Maven Central using Travis CI

Inspired by similiar project by (Toshiaki Maki)[https://github.com/making/travis-ci-maven-deploy-skelton] for deploying Maven projects using Travis CI.

``` console
$ git clone https://github.com/arakelian/travis-ci-gradle-deploy-skeleton
$ cd travis-ci-gradle-deploy-skeleton
$ cp -R deploy <path to your project>/
$ cp .travis.yml.template <path to your project>/.travis.yml

$ cd <path to your project>
$ export GITHUB_USER_SLASH_REPO=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*://' | sed 's/\.git//')

$ gem install travis
$ travis login
$ travis enable -r ${GITHUB_USER_SLASH_REPO}

$ export ENCRYPTION_PASSWORD=<password to encrypt>
$ openssl aes-256-cbc -pass pass:$ENCRYPTION_PASSWORD -in ~/.gnupg/secring.gpg -out deploy/secring.gpg.enc
$ openssl aes-256-cbc -pass pass:$ENCRYPTION_PASSWORD -in ~/.gnupg/pubring.gpg -out deploy/pubring.gpg.enc

$ travis encrypt --add -r ${GITHUB_USER_SLASH_REPO} SONATYPE_USERNAME=<sonatype username>
$ travis encrypt --add -r ${GITHUB_USER_SLASH_REPO} SONATYPE_PASSWORD=<sonatype password>
$ travis encrypt --add -r ${GITHUB_USER_SLASH_REPO} ENCRYPTION_PASSWORD=<password to encrypt>
$ travis encrypt --add -r ${GITHUB_USER_SLASH_REPO} GPG_KEYNAME=<gpg keyname (ex. 1C06698F)>
$ travis encrypt --add -r ${GITHUB_USER_SLASH_REPO} GPG_PASSPHRASE=<gpg passphrase>
```

Add the following elements in your pom.xml

``` gradle

if (project.hasProperty('SONATYPE_USERNAME')) {
    signing {
        sign configurations.archives
    }

    uploadArchives {
        repositories {
            // see: http://central.sonatype.org/pages/gradle.html
            mavenDeployer {
                beforeDeployment {
                    MavenDeployment deployment -> signing.signPom(deployment)
                }

                repository(url: "https://oss.sonatype.org/service/local/staging/deploy/maven2/") {
                    authentication(userName: SONATYPE_USERNAME, password: SONATYPE_PASSWORD)
                }

                snapshotRepository(url: "https://oss.sonatype.org/content/repositories/snapshots/") {
                    authentication(userName: SONATYPE_USERNAME, password: SONATYPE_PASSWORD)
                }

                pom.project {
                    name project.name
                    packaging 'jar'
                    description project.description

                    url 'https://github.com/<your github username>/' + project.name
                    scm {
                        connection 'scm:git:https://github.com/<your github username>/' + project.name + '.git'
                        developerConnection 'scm:git:git@github.com:<your github username>' + project.name + '.git'
                        url 'https://github.com/<your github username>/' + project.name + '.git'
                    }

                    licenses {
                        license {
                            name 'Apache License 2.0'
                            url 'https://www.apache.org/licenses/LICENSE-2.0'
                            distribution 'repo'
                        }
                    }

                    developers {
                        developer {
                            id = '<your github username>'
                            name = '<your name>'
                            email = '<your email>'
                        }
                    }
                }
            }
        }
    }
}

```
