# vscode remote development

> 로컬 VSCODE에서 원격 linux 서버로 접근하여 작업하고자 할 경우

## flow

### remote server

**check version**

```shell
cat /etc/os-release | grep PRETTY_NAME | awk -F"=" '{print $NF}'
"Oracle Linux Server 7.9"
```

### local

1. run vscode
2. install extention: `remote development`
3. move sidemenu: Remote Explorer
4. change select box: `Remotes (Tunnels/SSH)`
5. add ssh
   <img src="./assets/image-20230825113158845.png" alt="image-20230825113158845" style="zoom:50%;" />
   <img src="./assets/image-20230825113247228.png" alt="image-20230825113247228" style="zoom:50%;" />
6. enter password
7. open folder
   ![image-20230825113513572](./assets/image-20230825113513572.png)
8. **enjoy** 🎉
   <img src="./assets/image-20230825113855650.png" alt="image-20230825113855650" style="zoom:67%;" />

