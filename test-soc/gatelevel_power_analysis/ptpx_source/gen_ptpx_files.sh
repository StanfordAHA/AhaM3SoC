
# Netlist files
netlist_dir="netlist"
if [ -d $netlist_dir ]; then
    rm -rf $netlist_dir
fi
mkdir -p $netlist_dir
cp /sim/pohan/garnet_build/1203/31-cadence-innovus-signoff/outputs/design.vcs.pg.v                               ./$netlist_dir/design.v
cp /sim/pohan/garnet_build/1203/15-glb_top/25-cadence-innovus-signoff/outputs/design.vcs.pg.v                    ./$netlist_dir/glb_top.v
cp /sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.vcs.pg.v                                  ./$netlist_dir/glb_tile.v
cp /sim/pohan/garnet_build/1203/17-tile_array/outputs/tile_array.vcs.pg.v                                        ./$netlist_dir/tile_array.v
cp /sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/26-cadence-innovus-signoff/outputs/design.vcs.pg.v      ./$netlist_dir/Tile_PE.v
cp /sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/26-cadence-innovus-signoff/outputs/design.vcs.pg.v ./$netlist_dir/Tile_MemCore.v

# SPEF files
spef_dir="parasitics"
if [ -d $spef_dir ]; then
    rm -rf $spef_dir
fi
mkdir -p $spef_dir
cp /sim/pohan/garnet_build/1203/31-cadence-innovus-signoff/outputs/design.spef.gz                                ./$spef_dir/design.spef
cp /sim/pohan/garnet_build/1203/15-glb_top/25-cadence-innovus-signoff/outputs/design.spef.gz                     ./$spef_dir/glb_top.spef
cp /sim/pohan/garnet_build/1203/15-glb_top/7-glb_tile/outputs/glb_tile.spef.gz                                   ./$spef_dir/glb_tile.spef
cp /sim/pohan/garnet_build/1203/17-tile_array/outputs/tile_array.spef.gz                                         ./$spef_dir/tile_array.spef
cp /sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/26-cadence-innovus-signoff/outputs/design.spef.gz       ./$spef_dir/Tile_PE.spef
cp /sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/26-cadence-innovus-signoff/outputs/design.spef.gz  ./$spef_dir/Tile_MemCore.spef

# SDC files
sdc_dir="constraint"
if [ -d $sdc_dir ]; then
    rm -rf $sdc_dir
fi
mkdir -p $sdc_dir
cp /sim/pohan/garnet_build/1203/31-cadence-innovus-signoff/outputs/design.pt.sdc                                     ./$sdc_dir/design.sdc
cp /sim/pohan/garnet_build/1203/15-glb_top/25-cadence-innovus-signoff/outputs/design.pt.sdc                          ./$sdc_dir/glb_top.sdc
cp /sim/pohan/garnet_build/1130/15-glb_top/7-glb_tile/22-cadence-innovus-signoff/outputs/design.pt.sdc               ./$sdc_dir/glb_tile.sdc
cp /sim/pohan/garnet_build/1130/17-tile_array/25-cadence-innovus-signoff/outputs/design.pt.sdc                       ./$sdc_dir/tile_array.sdc
cp /sim/pohan/garnet_build/1130/17-tile_array/14-Tile_PE/26-cadence-innovus-signoff/outputs/design.pt.sdc            ./$sdc_dir/Tile_PE.sdc
cp /sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/26-cadence-innovus-signoff/outputs/design.pt.sdc       ./$sdc_dir/Tile_MemCore.sdc

# DB files
db_dir="timing"
if [ -d $db_dir ]; then
    rm -rf $db_dir
fi
mkdir -p $db_dir
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/gpio_1v2_e1-typical.db                                ./$db_dir/gpio_1v2_e1-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/gpio_1v2_n1-typical.db                                ./$db_dir/gpio_1v2_n1-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/sdio_1v8_e1-typical.db                                ./$db_dir/sdio_1v8_e1-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/sdio_1v8_n1-typical.db                                ./$db_dir/sdio_1v8_n1-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-hp-typical.db                           ./$db_dir/stdcells-base-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-lplvt-typical.db                        ./$db_dir/stdcells-base-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-lp-typical.db                           ./$db_dir/stdcells-base-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-lvt-typical.db                          ./$db_dir/stdcells-base-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-nom-typical.db                          ./$db_dir/stdcells-base-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-ulp-typical.db                          ./$db_dir/stdcells-base-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-base-ulvt-typical.db                         ./$db_dir/stdcells-base-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-hp-typical.db                            ./$db_dir/stdcells-clk-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-lplvt-typical.db                         ./$db_dir/stdcells-clk-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-lp-typical.db                            ./$db_dir/stdcells-clk-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-lvt-typical.db                           ./$db_dir/stdcells-clk-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-nom-typical.db                           ./$db_dir/stdcells-clk-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-ulp-typical.db                           ./$db_dir/stdcells-clk-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-clk-ulvt-typical.db                          ./$db_dir/stdcells-clk-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-hp-typical.db                         ./$db_dir/stdcells-dsclk1-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-lplvt-typical.db                      ./$db_dir/stdcells-dsclk1-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-lp-typical.db                         ./$db_dir/stdcells-dsclk1-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-lvt-typical.db                        ./$db_dir/stdcells-dsclk1-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-nom-typical.db                        ./$db_dir/stdcells-dsclk1-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-ulp-typical.db                        ./$db_dir/stdcells-dsclk1-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-dsclk1-ulvt-typical.db                       ./$db_dir/stdcells-dsclk1-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-hp-typical.db                         ./$db_dir/stdcells-ldrseq-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-lplvt-typical.db                      ./$db_dir/stdcells-ldrseq-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-lp-typical.db                         ./$db_dir/stdcells-ldrseq-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-lvt-typical.db                        ./$db_dir/stdcells-ldrseq-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-nom-typical.db                        ./$db_dir/stdcells-ldrseq-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-ulp-typical.db                        ./$db_dir/stdcells-ldrseq-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrseq-ulvt-typical.db                       ./$db_dir/stdcells-ldrseq-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-hp-typical.db                      ./$db_dir/stdcells-ldrsupseq-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-lplvt-typical.db                   ./$db_dir/stdcells-ldrsupseq-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-lp-typical.db                      ./$db_dir/stdcells-ldrsupseq-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-lvt-typical.db                     ./$db_dir/stdcells-ldrsupseq-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-nom-typical.db                     ./$db_dir/stdcells-ldrsupseq-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-ulp-typical.db                     ./$db_dir/stdcells-ldrsupseq-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-ldrsupseq-ulvt-typical.db                    ./$db_dir/stdcells-ldrsupseq-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-hp-typical.db                            ./$db_dir/stdcells-pwm-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-lplvt-typical.db                         ./$db_dir/stdcells-pwm-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-lp-typical.db                            ./$db_dir/stdcells-pwm-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-lvt-typical.db                           ./$db_dir/stdcells-pwm-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-nom-typical.db                           ./$db_dir/stdcells-pwm-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-ulp-typical.db                           ./$db_dir/stdcells-pwm-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-pwm-ulvt-typical.db                          ./$db_dir/stdcells-pwm-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-hp-typical.db                            ./$db_dir/stdcells-seq-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-lplvt-typical.db                         ./$db_dir/stdcells-seq-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-lp-typical.db                            ./$db_dir/stdcells-seq-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-lvt-typical.db                           ./$db_dir/stdcells-seq-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-nom-typical.db                           ./$db_dir/stdcells-seq-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-ulp-typical.db                           ./$db_dir/stdcells-seq-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-seq-ulvt-typical.db                          ./$db_dir/stdcells-seq-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-hp-typical.db                           ./$db_dir/stdcells-spcl-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-lplvt-typical.db                        ./$db_dir/stdcells-spcl-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-lp-typical.db                           ./$db_dir/stdcells-spcl-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-lvt-typical.db                          ./$db_dir/stdcells-spcl-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-nom-typical.db                          ./$db_dir/stdcells-spcl-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-ulp-typical.db                          ./$db_dir/stdcells-spcl-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-spcl-ulvt-typical.db                         ./$db_dir/stdcells-spcl-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-hp-typical.db                        ./$db_dir/stdcells-supbase-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-lplvt-typical.db                     ./$db_dir/stdcells-supbase-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-lp-typical.db                        ./$db_dir/stdcells-supbase-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-lvt-typical.db                       ./$db_dir/stdcells-supbase-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-nom-typical.db                       ./$db_dir/stdcells-supbase-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-ulp-typical.db                       ./$db_dir/stdcells-supbase-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supbase-ulvt-typical.db                      ./$db_dir/stdcells-supbase-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-hp-typical.db                         ./$db_dir/stdcells-supclk-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-lplvt-typical.db                      ./$db_dir/stdcells-supclk-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-lp-typical.db                         ./$db_dir/stdcells-supclk-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-lvt-typical.db                        ./$db_dir/stdcells-supclk-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-nom-typical.db                        ./$db_dir/stdcells-supclk-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-ulp-typical.db                        ./$db_dir/stdcells-supclk-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supclk-ulvt-typical.db                       ./$db_dir/stdcells-supclk-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-hp-typical.db                         ./$db_dir/stdcells-suppwm-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-lplvt-typical.db                      ./$db_dir/stdcells-suppwm-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-lp-typical.db                         ./$db_dir/stdcells-suppwm-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-lvt-typical.db                        ./$db_dir/stdcells-suppwm-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-nom-typical.db                        ./$db_dir/stdcells-suppwm-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-ulp-typical.db                        ./$db_dir/stdcells-suppwm-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-suppwm-ulvt-typical.db                       ./$db_dir/stdcells-suppwm-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-hp-typical.db                         ./$db_dir/stdcells-supseq-hp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-lplvt-typical.db                      ./$db_dir/stdcells-supseq-lplvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-lp-typical.db                         ./$db_dir/stdcells-supseq-lp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-lvt-typical.db                        ./$db_dir/stdcells-supseq-lvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-nom-typical.db                        ./$db_dir/stdcells-supseq-nom-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-ulp-typical.db                        ./$db_dir/stdcells-supseq-ulp-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/stdcells-supseq-ulvt-typical.db                       ./$db_dir/stdcells-supseq-ulvt-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/sup1v8_e1-typical.db                                  ./$db_dir/sup1v8_e1-typical.db
ln -sf /sim/pohan/garnet_build/1130/9-intel16-adk/outputs/adk/sup1v8_n1-typical.db                                  ./$db_dir/sup1v8_n1-typical.db
# SRAM DB files
ln -sf /sim/pohan/garnet_build/1130/17-tile_array/13-Tile_MemCore/13-gen_sram_macro/outputs/sram-typical.db          ./$db_dir/sram_mem_tile-typical.db
ln -sf /sim/pohan/garnet_build/1130/15-glb_top/7-glb_tile/11-gen_sram_macro/outputs/sram-typical.db                  ./$db_dir/sram_glb_tile-typical.db
ln -sf /sim/pohan/garnet_build/1203/13-gen_sram_macro_cpu/outputs/sram-typical.db                                    ./$db_dir/sram_cpu-typical.db
ln -sf /sim/pohan/garnet_build/1203/14-gen_sram_macro_nic/outputs/sram-typical.db                                    ./$db_dir/sram_nic-typical.db
