local json = dofile("/opt/awsautodns/json.lua")

local hexset = {"0" ,"1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}

math.randomseed(os.time(os.date("!*t")))

local function log(tLog)
        local f, err = io.open("/var/log/awsautodns.log", "a+")
        if not f then
                error(err.." opening file /var/log/awsautodns.log", 2)
        end
        f:write(os.date('%Y-%m-%d %H:%M:%S')..": "..tLog.."\n")
        f:close()
        return true
end

local function logerror(tLog)
        log(tLog)
        error(tLog)
end

local function execute(tExecute)
        local tName, err, f
        repeat
                tName = "/tmp/"
                for i = 1, 16 do
                        tName = tName..hexset[math.random(1, 16)]
                end
                f = io.open(tName, "r")
        until not f
        os.execute(tExecute.." >> "..tName)
        f, err  = io.open(tName, "r")
        if not f then
                error(err.." opening file "..tName)
        end
        local contents = f:read("*a")
        f:close()
        os.execute("rm -f "..tName)
        return contents
end
--Get the privateip
local a = execute("ifconfig eth0 | grep 'inet '")
local privateip = string.sub(a, ({string.find(a, "inet")})[2] + 2, string.find(a, "netmask") - 3)
local instanceid, hostedzoneid, publicip, domain
--Get the instanceid and publicip
a = json.decode(execute("aws ec2 describe-instances"))
for _, v in pairs(a.Reservations) do
        if v.Instances then
                if v.Instances[1].PrivateIpAddress == privateip then
                        instanceid = v.Instances[1].InstanceId
                        publicip = v.Instances[1].PublicIpAddress
                        break
                end
        end
end

if not instanceid then
        log("Could not find instance with IP "..privateip)
        error("See /var/log/awsautodns.log for details")
end
--Get the relavent tags
a = json.decode(execute('aws ec2 describe-tags --filters "Name=resource-id,Values='..instanceid..'" "Name=key,Values=autodnsdomain"')).Tags
if #a == 0 then
        logerror("Instance "..instanceid.." does not have tag \"autodnsdomain\"")
end
domain = a[1].Value

a = json.decode(execute('aws ec2 describe-tags --filters "Name=resource-id,Values='..instanceid..'" "Name=key,Values=autodnshostedzoneid"')).Tags
if #a == 0 then
        logerror("Instance "..instanceid.." does not have tag \"autodnshostedzoneid\"")
end
hostedzoneid = a[1].Value

--Prepare the changes.json change batch
local f, err = io.open("/opt/awsautodns/changes.json", "r")
if not f then
        logerror(err.." opening file /opt/awsautodns/changes.json")
end

local changes = json.decode(f:read("*a"))
f:close()

changes.Changes[1].ResourceRecordSet.ResourceRecords[1].Value = publicip
changes.Changes[1].ResourceRecordSet.Name = domain

f = io.open("/opt/awsautodns/changes.json", "w+")
f:write(json.encode(changes))
f:close()

--Update the DNS record
a = json.decode(execute("aws route53 change-resource-record-sets --hosted-zone-id "..hostedzoneid.." --change-batch file:///opt/awsautodns/changes.json"))
log("Updated the DNS record of hosted zone ID "..hostedzoneid.." to point "..domain.." to "..publicip..". Change ID: "..a.ChangeInfo.Id..".")
