{async, collect, select, project, where, sleep, first} = require "fairmont"

module.exports = async (config) ->
  {ec2} = yield require("./index")(config.aws.region, config.profile)
  {fullName} = config.environmentVariables

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

  waitFor = (status) ->
    async (id) ->
      while true
        console.error "  --> waiting on #{id}"
        yield sleep 10000
        subnet = yield get id
        if subnet.Status == status
          console.error "  --> done waiting on #{id}"
          return

  waitForAvailable = waitFor "available"
  waitForInUse = waitFor "in-use"

  detach = async (id, attachmentID) ->
    yield ec2.detachNetworkInterface
      AttachmentId: attachmentID
      Force: true

    console.log "  --> detatching #{id}..."
    yield waitForAvailable id

  Delete = async (id) ->
    console.log "  --> deleting #{id}..."
    yield ec2.deleteNetworkInterface
      NetworkInterfaceId: id

  attachedToLambdas = (eni) -> ///#{fullName}///.test eni.RequesterId

  purge = async ->
    # Collect any ENIs used by this stacks's Lambdas
    ENIs = yield list()
    ENIs = collect select attachedToLambdas, ENIs

    # Detach any attached ENIs
    attachedENIs = collect where Status: "in-use", ENIs
    yield Promise.all (detach e.NetworkInterfaceId, e.Attachment.AttachmentId for e in attachedENIs)

    # Destroy all the ENIs
    yield Promise.all (Delete e.NetworkInterfaceId for e in ENIs)


  {purge}
