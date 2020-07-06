#!/bin/bash


echo "start: update placeholders such as clusterResourceId, clusterRegion, WSID, WSKEY and Image etc.."

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)
   VALUE=$(echo $ARGUMENT | cut -f2 -d=)

   case "$KEY" in
           ClusterResourceId) ClusterResourceId=$VALUE ;;
           ClusterRegion) ClusterRegion=$VALUE ;;
           CIRelease) CI_RELEASE=$VALUE ;;
           CIImageTagSuffix) CI_IMAGE_TAG_SUFFIX=$VALUE ;;
           WSIDBase64Encoded) WSID=$VALUE ;;
           WSKEYBase64Encoded) WSKEY=$VALUE ;;

           *)
    esac
done

echo "clusterResourceId:$ClusterResourceId"
echo "replace cluster resource id"
sed -i "s=VALUE_AKS_RESOURCE_ID_VALUE=$ClusterResourceId=g" omsagent.yaml

echo "clusterRegion:$ClusterRegion"
echo "replace cluster region"
sed -i "s/VALUE_AKS_RESOURCE_REGION_VALUE/$ClusterRegion/g" omsagent.yaml

echo "replace linux agent image"
linuxAgentImageTag=$CI_RELEASE$CI_IMAGE_TAG_SUFFIX
echo "Linux Agent Image Tag:"$linuxAgentImageTag

linuxAgentImage="mcr.microsoft.com/azuremonitor/containerinsights/${CI_RELEASE}:${linuxAgentImageTag}"
imagePrefixLinuxAgent="mcr.microsoft.com/azuremonitor/containerinsights/ciprod:ciprod[0-9]*"
sed -i "s=$imagePrefixLinuxAgent=$linuxAgentImage=g" omsagent.yaml

echo "replace windows agent image"
windowsAgentImageTag="win-"$CI_RELEASE$CI_IMAGE_TAG_SUFFIX
echo "Windows Agent Image Tag:"$windowsAgentImageTag

windowsAgentImage="mcr.microsoft.com/azuremonitor/containerinsights/${CI_RELEASE}:${windowsAgentImageTag}"
imagePrefixWindowsAgent="mcr.microsoft.com/azuremonitor/containerinsights/ciprod:win-ciprod[0-9]*"
sed -i "s=$imagePrefixWindowsAgent/$windowsAgentImage=g" omsagent.yaml

echo "replace base64 encoded log analytics workspace id"
echo "Base64 Encoded workspace id: ${WSID}"
sed -i "s/VALUE_WSID/$WSID/g" omsagent.yaml

echo "replace base64 encoded log analytics workspace key"
sed -i "s/VALUE_KEY/$WSKEY/g" omsagent.yaml

echo "end: update placeholders such as clusterResourceId, clusterRegion, WSID, WSKEY and Image etc.."