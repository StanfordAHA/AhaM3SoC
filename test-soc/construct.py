# =============================================================================
# construct.py
# =============================================================================
# Garnet SoC RTL Simulation
#
# Author    : Gedeon Nyengele
# Date      : April 5, 2020
# =============================================================================

import os
from mflowgen.components import Graph, Step


def construct():
    g = Graph()

    this_dir = os.path.dirname(os.path.abspath(__file__))

    #---------------------------------------------------------------------------
    # Paths to design repos
    #
    # Assumption:
    #   - test-soc (mflowgen design directory) is located at same level as
    #     design repo directories
    #---------------------------------------------------------------------------

    # depends on where you placed build folder (place it at same level for ../../)
    shared_top_dir  = os.path.abspath(os.path.join(this_dir, "../../"))
    arm_ip_dir      = os.path.join(shared_top_dir, "aham3soc_armip")
    aha_ip_dir      = os.path.join(shared_top_dir, "aham3soc")
    garnet_dir      = os.path.join(shared_top_dir, "garnet")
    gate_level_dir  = os.path.join(shared_top_dir, "gate_level_dec_pwr")

    # -------------------------------------------------------------------------
    # Supported tests
    # -------------------------------------------------------------------------

    test_names = [
        # CPU Tests
        'apb_mux_test',
        'hello_test',
        'memory_test',
        'dma_single_channel',
        'default_slaves_test',
        #'interrupts_test',
        'tlx_test',
        'cgra_test',
        'cgra_reset_test',
        'app_test_onyx_dense_sparse',
        #'master_clock_test',
        #'app_tlx_test',
        #'app_test_stage1',
        #'app_test_stage_relocation',
        #'harris_test',
        #'app_test_two_images_stage1',
        #'app_test_two_images',
        #'app_test_reconfig',
        #'app_test_reconfig_pipeline',
        #'app_test_2_kernels_1_cgra',
       # 'cascade_test',
        #'resnet_test',
        #'resnet_test_i4_o3',
        #'demosaic_complex',
        #'demosaic_complex_twice',
        #'demosaic_complex_harris',
        #'resnet_pond',
        #'resnet_layer_gen',

        # CXDT Tests
        #'discovery',
    ]

    # -------------------------------------------------------------------------
    # Parameters
    # -------------------------------------------------------------------------

    parameters = {
        'construct_file': __file__,
        'design_name': 'test-soc',
        'soc_only'  : False,
        'interconnect_only' : False,
        'array_width': 32,
        'array_height': 16,
        'clock_period': 1.0,
        'ARM_IP_DIR': arm_ip_dir,
        'AHA_IP_DIR': aha_ip_dir,
        'GATE_LEVEL_DIR': gate_level_dir,
        'GARNET_DIR': "/sim/kkoul/aha/garnet",
        'TLX_FWD_DATA_LO_WIDTH': 16,
        'TLX_REV_DATA_LO_WIDTH': 45,
        'IMPL_VIEW': 'SIM', # can be SIM or ASIC
        'TEST_VIEW': 'JTAG', # can be JTAG or NO_JTAG
        'PROCESS': 'INTEL', # can be GF or TSMC if IMPL_VIEW == ASIC
        'SIMULATOR': 'VCS', # can be wither VCS or XCELIUM
        'INCLUDE_XGCD' : False,
    }

    # -------------------------------------------------------------------------
    # Custom steps
    # -------------------------------------------------------------------------

    garnet_rtl  	    = Step(parameters['GARNET_DIR'] + '/mflowgen/common/rtl')
    compile_design  	= Step(this_dir + '/compile_design')
    build_test      	= Step(this_dir + '/build_test')
    run_test        	= Step(this_dir + '/run_test')
    verdict         	= Step(this_dir + '/verdict')

    # -------------------------------------------------------------------------
    # Parallelize test build and run
    # -------------------------------------------------------------------------

    test_count = len(test_names)
    build_steps = list(map((lambda _: build_test.clone()), range(test_count)))
    run_steps = list(map((lambda _: run_test.clone()), range(test_count)))

    for step, name in zip(build_steps, test_names):
        step.set_name('build_' + name)
    for step, name in zip(run_steps, test_names):
        step.set_name('run_' + name)

    # -------------------------------------------------------------------------
    # Input/output dependencies
    # -------------------------------------------------------------------------

    # 'compile_design' step produces a simulation executable and its accompanying collateral
    compile_design.extend_inputs(['design.v'])

    if parameters['SIMULATOR'] == 'VCS':
        compile_design.extend_outputs(['simv', 'simv.daidir'])
    elif parameters['SIMULATOR'] == 'XCELIUM':
        compile_design.extend_outputs(['xcelium.d'])

    # 'build_test' produces final images for both the CXDT and CPU
    for step in build_steps:
        if parameters['TEST_VIEW'] == 'JTAG':
            step.extend_outputs(['CXDT.bin'])
        else:
            step.extend_outputs(['ROM.hex'])

    # 'run_test' takes either CXDT.bin or ROM.hex
    for step, test in zip(run_steps, test_names):
        if parameters['TEST_VIEW'] == 'JTAG':
            step.extend_inputs(['CXDT.bin'])
        else:
            step.extend_inputs(['ROM.hex'])
        if parameters['SIMULATOR'] == 'XCELIUM':
            step.extend_inputs(['xcelium.d'])
        else:
            step.extend_inputs(['simv', 'simv.daidir'])
        step.extend_outputs(['SIM_run_' + test + '.log'])


    # 'verdict' consumes the run logs
    run_logs = list(map((lambda test: 'SIM_run_' + test + '.log'), test_names))
    verdict.extend_inputs(run_logs)

    # -------------------------------------------------------------------------
    # Graph -- Add nodes
    # -------------------------------------------------------------------------

    g.add_step(garnet_rtl)
    g.add_step(compile_design)

    for s in build_steps:
        g.add_step(s)

    for s in run_steps:
        g.add_step(s)

    g.add_step(verdict)

    # -------------------------------------------------------------------------
    # Graph -- Add edges
    # -------------------------------------------------------------------------

    g.connect_by_name(garnet_rtl, compile_design)

    for r, b in zip(run_steps, build_steps):
        g.connect_by_name(b, r)
        g.connect_by_name(compile_design, r)
        g.connect_by_name(r, verdict)

    # -------------------------------------------------------------------------
    # Set general parameters
    # -------------------------------------------------------------------------

    g.update_params(parameters)

    # -------------------------------------------------------------------------
    # Set node-specific parameters
    # -------------------------------------------------------------------------

    for step, test in zip(build_steps, test_names):
        step.update_params({'TEST_NAME': test})
    for step, test in zip(run_steps, test_names):
        step.update_params({'TEST_NAME': test})
        step.update_params({'SIMULATOR': parameters['SIMULATOR']})
        step.update_params({'IMPL_VIEW': parameters['IMPL_VIEW']})
        step.update_params({'TEST_VIEW': parameters['TEST_VIEW']})


    # -------------------------------------------------------------------------
    # Pre-conditions
    # -------------------------------------------------------------------------

    # 'verdict' requires all tests to have passed
    verdict.extend_preconditions(
        ["assert 'TEST PASSED' in File('inputs/" + run_log +
         "', enable_case_sensitive = True)" for run_log in run_logs]
    )

    # -------------------------------------------------------------------------
    # Post-conditions
    # -------------------------------------------------------------------------

    # 'compile_tbench' must be successful
    compile_design.extend_postconditions([
        "assert 'Error' not in File('SIM_compile.log', enable_case_sensitive = True)"
    ])

    return g


if __name__ == '__main__':
    g = construct()
