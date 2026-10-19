#!/usr/bin/env bash
# Usage: scripts/summarise.sh <monitor-log>
[ $# -eq 1 ] && [ -f "$1" ] || { echo "usage: $0 <monitor-log>"; exit 1; }
awk '
function ep(t,  y,m,d,H,M,S,era,yoe,doy,doe){y=substr(t,1,4)+0;m=substr(t,6,2)+0;d=substr(t,9,2)+0
  H=substr(t,12,2)+0;M=substr(t,15,2)+0;S=substr(t,18,2)+0; if(m<=2)y--
  era=int(y/400);yoe=y-era*400;doy=int((153*(m+(m>2?-3:9))+2)/5)+d-1;doe=yoe*365+int(yoe/4)-int(yoe/100)+doy
  return (era*146097+doe)*86400+H*3600+M*60+S}
NF>=2 && $2 ~ /^(OK|FAIL)$/ {
  n++; if(n==1)first=$1; last=$1
  if($2=="FAIL") f++
  else if(match($0,/"version":"[^"]*"/)){v=substr($0,RSTART+11,RLENGTH-12); c[v]++; e=ep($1)
    if(!(v in fs)||e<fs[v])fs[v]=e; if(!(v in ls)||e>ls[v])ls[v]=e}
}
END{
  printf "Total requests:  %d\nFailed requests: %d\nFirst timestamp: %s\nLast timestamp:  %s\nResponses per version:\n",n,f+0,first,last
  nv=0; for(v in c){printf "  %s: %d\n",v,c[v]; nv++; if(mf==""||fs[v]>mf)mf=fs[v]; if(ml==""||ls[v]<ml)ml=ls[v]}
  w=0; if(nv>=2){w=ml-mf; if(w<0)w=0}
  printf "Mixed-version window (s): %d  (meaningful for ONE old->new transition)\n",w
}' "$1"
