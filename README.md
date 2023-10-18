# BTRFS-Size
A script that will print out a list of BTRFS subvolumes along with their size in megabytes and their name

You will need to enable quotas first. Run this command as root: `btrfs quota enable /`

For more information check out this [blog entry](https://poisonpacket.wordpress.com/2015/05/26/btrfs-snapshot-size-disk-usage/).

Example output:
```
Snapshot / Subvolume                                                            Total Exclusive Data    ID
==============================================================================================================
@                                                                                            16.00KB   256
@/home                                                                                      346.98MB   257
@/boot/grub2/x86_64-efi                                                                       4.18MB   258
@/boot/grub2/i386-pc                                                                         16.00KB   259
@/.snapshots                                                                                640.00KB   260
@/.snapshots/1/snapshot                                                                      82.39GB   261
@/.snapshots/391/snapshot                                                                    81.52GB   651
@/.snapshots/392/snapshot                                                                    81.54GB   652
@/.snapshots/393/snapshot                                                                    81.65GB   653
@/.snapshots/394/snapshot                                                                    81.59GB   654
@/.snapshots/397/snapshot                                                                    81.85GB   657
@/.snapshots/398/snapshot                                                                    82.22GB   658
@/.snapshots/399/snapshot                                                                    82.24GB   659
@/.snapshots/400/snapshot                                                                    82.05GB   660
@/.snapshots/405/snapshot                                                                    82.04GB   665
@/.snapshots/406/snapshot                                                                    82.32GB   666
@/.snapshots/407/snapshot                                                                    82.31GB   667
@/.snapshots/408/snapshot                                                                    82.31GB   668
@/.snapshots/409/snapshot                                                                    82.34GB   669
@/.snapshots/410/snapshot                                                                    82.29GB   670
@/.snapshots/411/snapshot                                                                    82.32GB   671
@/.snapshots/412/snapshot                                                                    82.51GB   672
@/.snapshots/413/snapshot                                                                    82.52GB   673
@/.snapshots/414/snapshot                                                                    82.38GB   674
==============================================================================================================
                                                                Exclusive Total: 14.89GB   
```
