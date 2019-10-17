
import argparse
import os
import requests
import json

parser = argparse.ArgumentParser()
parser.add_argument("keyId", help="ASoC API KeyID to login to ASoC")
parser.add_argument("keySecret", help="ASoC API Key Secret to login to ASoC")
parser.add_argument("appId", help="ASoC AppId to associate scan results")
parser.add_argument("mobileapp", help="Path to mobile app (apk/ipa)")
parser.add_argument("scanName", help="Scan to complete")

args = parser.parse_args()

if(args.mobileapp is not None and os.path.exists(args.mobileapp)==False):
	print("Mobile app path does not exist")
	sys.exit(1)
else:
	appPath = args.mobileapp
	
apiKeyId = args.keyId
apiKeySecret = args.keySecret
appId = args.appId
scanName = args.scanName
mobileApp = args.mobileapp
split = mobileApp.split("/")
fileName = split[-1]
#print(fileName)

def asoc_login(keyId, keySecret):
	data = '{"KeyId": "' + keyId + '","KeySecret": "' + keySecret + '"}'
	r = requests.post('https://cloud.appscan.com/api/V2/Account/ApiKeyLogin', json = json.loads(data))
	if(r.status_code == 200):
		jsonToken = r.json()
		return jsonToken["Token"]
	else:
		return False

def asoc_logout(token):
	r = requests.get('https://cloud.appscan.com/api/V2/Account/Logout', headers={"Authorization":"Bearer "+token})
	if(r.status_code == 200):
		return True
	else:
		return False
	
def asoc_fileupload(token, filePath, fileName):
	files = {'fileToUpload': (fileName, open(filePath, 'rb'))}
	r = requests.post("https://cloud.appscan.com/api/v2/FileUpload", headers={"Authorization":"Bearer "+token}, files=files)
	if(r.status_code == 201):
		jsonFile = r.json()
		return jsonFile["FileId"]
	else:
		return False
	
def asoc_createscan(fileId, appId, scanName):
	data = '{"ApplicationFileId": "' + fileId + '","AppId": "' + appId + '","ScanName": "' + scanName + '"}'
	r = requests.post('https://cloud.appscan.com/api/v2/Scans/MobileAnalyzer', headers={"Authorization":"Bearer "+token}, json=json.loads(data))
	if(r.status_code == 201):
		resultJson = r.json()
		return resultJson["Id"]
	else:
		return False


token = asoc_login(apiKeyId, apiKeySecret)
if(!token):
	print("Login: True")
	
print("Uploading File:")
fileId = asoc_fileupload(token, mobileApp, "demo.apk")
print("File Uploaded. File Id: " + str(fileId))
scanId = asoc_createscan(fileId, appId, scanName)
print("Created Scan. Scan Id: " + str(scanId))
print("Logged Out:" + str(asoc_logout(token)))
