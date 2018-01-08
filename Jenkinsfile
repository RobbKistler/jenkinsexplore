#!/usr/bin/env groovy

def causes = currentBuild.rawBuild.getCauses()
println("CAUSES: ${causes}")
@NonCPS def causeDescription = currentBuild.rawBuild.getCause(hudson.model.Cause$TimerTrigger.TimerTriggerCause).shortDescription
println("CAUSE DESCRIPTION: ${causeDescription}")
jobProperties = [buildDiscarder(daysToKeepStr: '30')]


if (isMasterBranch()) {
  jobProperties << pipelineTriggers([cron('* * * * *')])
}

println("PROPERTIES: ${jobProperties}")

properties(jobProperties)

def isMasterBranch() {
  env.BRANCH_NAME == 'master'
}

println("DESCRIPTION: ${currentBuild.description}")
println("DISPLAY: ${currentBuild.displayName}")
/*
def awsCredentials = [[$class: 'AmazonWebServicesCredentialsBinding',
  accessKeyVariable: 'AWS_ACCESS_KEY_ID',
  credentialsId: 'docker-qa@docker-core.aws',
  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'],
  file(credentialsId: 'docker-qa.docker-core.pem', variable: 'AWS_KEY_PATH')]
*/

def testStepName(config) {
  "TEST distro ${config.distro}" 
}

def testStepBody(config) {
  { ->
    sh("echo make DISTRO=${config.distro} TESTNAME=E2E-CI-${BRANCH_NAME}-BUILD-${BUILD_ID} AWS_KEY_NAME=docker-qa ci")
    sh("env")
    if (config.distro == 'centos')
      sh("echo This is centos")
  }
}


// Returns a [name:closure] entry suitable for parallel()
def testStep(config) {
  return [(testStepName(config)) : (testStepBody(config))]
}

// Test configs to run for PR builds
def matrix = [[distro:'ubuntu'], [distro:'centos']]

// Aditional test configs for merges to master branch
if (isMasterBranch()) {
  matrix += [[distro:'centos']]
  // Just examples to illustrate use case
  // matrix << [[distro:'centos'  ],
  //            [distro:'debian'  ],
  //            [distro:'sles'    ],
  //            [distro:'linuxkit'],
  //            [distro:'rhel'    ]]
}

def steps = [:]
for (config in matrix) {
  steps << testStep(config)
}

try {
    stage('build') {
        // TODO: checkout scm, build and push e2e docker image in a wrappedNode
        myFile = new File("${env.WORKSPACE}/somefile}")
        if (file.exists() && file.length() > 0) {
          echo("File is non-zero")
        } else {
          echo("File is missing or zero")
        }

    }

    stage('test') {
        node() {
            // TODO: move checkout to 'build' stag
            checkout scm
                parallel(steps) 
        }
    }
} catch(err) {
   echo("SEND SLACK HERE")
   message = """
${env.CHANGE_AUTHOR}: <${env.CHANGE_URL}|PR: ${env.CHANGE_ID}> ${env.CHANGE_TITLE}
FAILED - See <${env.BUILD_URL}/console|the Jenkins console for job ${env.BUILD_ID}>
"""
   echo("Error: ${err}")
   echo("Slack message: ${message}")

   throw err
}

