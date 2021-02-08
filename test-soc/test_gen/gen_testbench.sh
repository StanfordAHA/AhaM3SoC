#!/bin/bash

# Build up the flags we want to pass to python garnet.v
flags="--width $array_width --height $array_height --pipeline_config_interval $pipeline_config_interval -v --interconnect-only"
map_flags="--width $array_width --height $array_height --pipeline_config_interval $pipeline_config_interval --interconnect-only"

if [ ${PWR_AWARE} = "False" ]; then
  flags="$flags --no-pd"
  map_flags="$map_flags --no-pd"
fi

# Clone AHA repo
git clone https://github.com/StanfordAHA/aha.git
cd aha
# install the aha wrapper script
pip install -e .

# Prune docker images...
yes | docker image prune -a --filter "until=6h" --filter=label='description=garnet' || true
docker container prune -f
# pull docker image from docker hub
docker pull stanfordaha/garnet:latest

# run the container in the background and delete it when it exits
# (this will print out the name of the container to attach to)
container_name=$(aha docker)
echo "container-name: $container_name"

echo $app_to_run
space=" "
app_to_run_space=${app_to_run//,/$space }
echo $app_to_run_space

docker exec $container_name /bin/bash -c "rm -rf /aha/garnet"
# Clone local garnet repo to prevent copying untracked files
git clone $GARNET_HOME ./garnet
docker cp ./garnet $container_name:/aha/garnet
# run the tests in the container and get all relevant files (tb, place file)
docker exec $container_name /bin/bash -c \
  "source /cad/modules/tcl/init/bash;
   apt update;
   module load xcelium;
   source /aha/bin/activate;
   aha garnet ${flags};
   cd garnet;
   sed -i 's|tester.expect(self.circuit.read_config_data, value)|# removed expect|' tbg.py;"


for app in $app_to_run_space; do
echo $app;
docker exec $container_name /bin/bash -c \
  "source /aha/bin/activate;
   cd garnet;
   aha halide $app;
   aha map $app ${map_flags};
   aha test $app;"
done



for app_path in $app_to_run_space; do
echo $app;
prefix1="tests/"
prefix2="apps/"
app=${app_path//$prefix1/}
app=${app//$prefix2/}
# Copy the testbench, input file, and placement file out of the container
docker cp $container_name:/aha/garnet/temp/design.place ../outputs/${app}_design.place
docker cp $container_name:/aha/Halide-to-Hardware/apps/hardware_benchmarks/${app_path}/bin/input.raw ../outputs/${app}_input.raw
docker cp $container_name:/aha/Halide-to-Hardware/apps/hardware_benchmarks/${app_path}/bin/gold.raw ../outputs/${app}_gold.raw
docker cp $container_name:/aha/Halide-to-Hardware/apps/hardware_benchmarks/${app_path}/bin/${app}.bs ../outputs/${app}.bs

done

# Kill the container
docker kill $container_name
echo "killed docker container $container_name"
cd $current_dir
