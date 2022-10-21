package main

import (
	"time"
	"fmt"
	"github.com/appleboy/easyssh-proxy"
	"os"
)

var fixIP = os.Getenv("VM_IP")
var fixPass = os.Getenv("VM_SECRET")
var scriptToRun = os.Getenv("scriptrun")



func fixCMD() string{
	ssh := &easyssh.MakeConfig{
		User:   "vmware-system-user",
		Server: fixIP,
		Password: fixPass,
		Port:    "22",
		Timeout: 60 * time.Second,
	}
	stdout, stderr, done, err := ssh.Run(scriptToRun, 60*time.Second)
	if err != nil {
		panic("Can't run remote command: " + err.Error())
	} else {
		fmt.Println("don is :", done, "stdout is :", stdout, ";   stderr is :", stderr)
	}
	return stdout
}


func main() {
	fixCMD()
}
