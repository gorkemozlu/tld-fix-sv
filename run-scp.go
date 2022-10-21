package main

import (
	"os"
	"fmt"
	"time"
	"github.com/appleboy/easyssh-proxy"
)

var fixIP = os.Getenv("VM_IP")
var fixPass = os.Getenv("VM_SECRET")

func fixCMD() string{
	ssh := &easyssh.MakeConfig{
		User:   "vmware-system-user",
		Server: fixIP,
		Password: fixPass,
		Port:    "22",
		Timeout: 60 * time.Second,
	}
	err := ssh.Scp("/opt/bitnami/tld-local.sh", "/tmp/tld-local.sh")

	// Handle errors
	if err != nil {
		panic("Can't run remote command: " + err.Error())
	} else {
		fmt.Println("success")
	}
	return "ok"
}


func main() {
	fixCMD()
}
