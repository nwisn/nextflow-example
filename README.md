# Nextflow 

## Why use Nextflow?

### Faster prototyping
Nextflow allows you to write a computational pipeline by making it simpler to put together many different tasks. You may reuse your existing scripts and tools and you don't need to learn a new language or API to start using it.

### Reproducibility
Nextflow supports Docker container technology, and is integrated with the GitHub code sharing platform, allowing you to write self-contained pipelines, manage versions and to rapidly reproduce any former configuration.

### Portability
Nextflow provides an abstraction layer between your pipeline's logic and the execution layer, so that it can be executed on multiple platforms without it changing. It provides out of the box executors for Kubernetes, Amazon AWS and Google Cloud platforms.

### Unified Parallelism
Nextflow is based on the dataflow programming model which greatly simplifies writing complex distributed pipelines. Parallelisation is implicitly defined by the processes input and output declarations. The resulting applications are inherently parallel and can scale-up or scale-out, transparently, without having to adapt to a specific platform architecture.

### Continuous checkpoints
All the intermediate results produced during the pipeline execution are automatically tracked. This allows you to resume its execution, from the last successfully executed step, no matter what the reason was for it stopping.


## Installation

Nextflow documentation can be found at [https://www.nextflow.io/](https://www.nextflow.io/). In particular, the Get Started section is [here](https://www.nextflow.io/docs/latest/getstarted.html).

Install on MacOS using `curl`:

```
curl -s https://get.nextflow.io | bash
```

Then move the `nextflow` file to a directory accessible by your `$PATH`: 

```
mv nextflow /usr/local/bin/
```

Our Nextflow script `pipeline.nf` can then be run from the project directory via the terminal:

```
nextflow run pipeline.nf
```


### Java issues

Nextflow has only been tested on `Java8` - `Java11`, but Java has newer versions. Find the version and location of previous Java installations on your machine:

```
/usr/libexec/java_home -V
```

To install one of these older versions of on MacOS, install `Homebrew` if you haven't already:

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

and then:

```
brew update
brew tap homebrew/cask-versions
brew cask install java11
```


To switch between Java versions, add them to your `~/.bash_profile` to create aliases to change `JAVA_HOME`:

```
export JAVA_12_HOME=$(/usr/libexec/java_home -v12)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

alias java12='export JAVA_HOME=$JAVA_12_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# default to Java 11
java11

```

To enact the changes, source the file and verify the version change

```
source ~/.bash_profile
```

Switch between versions and verify the aliases work

```
java -version
java12
java -version
java11
```


# Docker integration

If you haven't already, install Docker on your machine from their website [https://docs.docker.com/docker-for-mac/install/](https://docs.docker.com/docker-for-mac/install/). The Nextflow pipeline is simple to then integrate with Docker. First, we must create a `nextflow.config` file, and add Docker `runOptions` so we can mount our local filesystem.

```
docker {
    runOptions= "-v $HOME:$HOME"
}
```

Next, we must build a Docker image if one doesn't already exist. For our example to work, we need to modify an existing image to include the `optparse` R package. 

We could create a `Dockerfile` in the project directory, and derive a new image from a `rocker` image:

```
# Base image https://hub.docker.com/u/rocker/
FROM rocker/r-ubuntu:18.04

# install packages
RUN Rscript -e "install.packages(c('optparse'))"
```

We would then build the image (you must change `myname/myimage` to your Docker name):

```
docker build -t myname/myimage .
```

Alternatively, we can use an image from Docker Hub that has `optparse` already installed:

```
docker pull qrouchon/r-base-plus
```

Now the entire pipeline can be run in the container by specifying the Docker image name in the call to Nextflow:


```
nextflow run pipeline.nf -with-docker qrouchon/r-base-plus
```


If we want to assign different Docker images to different parts of the pipeline (for example, some parts are in R, python, Matlab, etc), we can edit the `nextflow.config` file to assign container names to each process, which have names `stage1` and `stage2` in our example.

```
docker {
    runOptions= "-v $HOME:$HOME"
    enabled = true
}

process {
    withName:stage1 {
        container = 'qrouchon/r-base-plus'
    }
    withName:stage2 {
        container = 'qrouchon/r-base-plus'
    }
}
```

After adding the `enabled = true` flag, we no longer need to use the `-with-docker` flag in calling Nextflow; it will automatically use the containers we specified:

```
nextflow run pipeline.nf 
```

We can verify this is actually using Docker by changing containers to ones that don't have `optparse` installed, and watching it crash.
