ssh -o "StrictHostKeyChecking=no" core@bootstrap.gw.lo "journalctl -b -f -u release-image.service -u bootkube.service"

