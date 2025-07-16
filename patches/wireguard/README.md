# Imported Wireguard patches

src: [LOS](https://github.com/LineageOS/android_kernel_oneplus_sm8250/commits/lineage-20/drivers/net/wireguard)

#### Oldest
`git log --reverse --oneline -- drivers/net/wireguard | head -1`

#### Newest
`git log --oneline -- drivers/net/wireguard | head -1`

#### Generate patches
`git format-patch --output-directory ./wireguard-patches 8187202360a0^..HEAD -- drivers/net/wireguard`

