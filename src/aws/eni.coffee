{async, collect, select, project, where, sleep, first} = require "fairmont"

module.exports = async (config) ->
  {ec2} = yield require("./index")(config.aws.region, config.profile)

  list = async ->
    {NetworkInterfaces} = yield ec2.describeNetworkInterfaces
      Filters: [
        Name: "subnet-id"
        Values: config.aws.vpc.subnets
      ]
    NetworkInterfaces

  get = async (id) ->
    try
      {NetworkInterfaces} = yield ec2.describeNetworkInterfaces
        NetworkInterfaceIds: [ id ]
      first NetworkInterfaces
    catch e
      false

  isDetached = async (id) ->
    subnet = yield get id
    subnet.Status == "available"

  detach = async (id, attachmentID) ->
    yield ec2.detachNetworkInterface
      AttachmentId: attachmentID
      Force: true

    console.log "detatched #{id}"
    while true
      console.log "waiting on #{id}"
      yield sleep 10000
      if yield isDetached id
        console.log "done waiting on #{id}"
        return

  Delete = async (id) ->
    console.log "deleting #{id}"
    yield ec2.deleteNetworkInterface
      NetworkInterfaceId: id


  attachedToLambdas = (eni) ->
    ///#{config.environmentVariables.fullName}///.test eni.RequesterId

  purge = async ->
    # Collect any ENIs used by this stacks's Lambdas
    ENIs = yield list()
    ENIs = collect select attachedToLambdas, ENIs
    console.log ENIs

    # Detach any attached ENIs
    attachedENIs = collect where Status: "in-use", ENIs
    yield Promise.all (detach e.NetworkInterfaceId, e.Attachment.AttachmentId for e in attachedENIs)

    # Destroy all the ENIs
    yield Promise.all (Delete e.NetworkInterfaceId for e in ENIs)


  {purge}
