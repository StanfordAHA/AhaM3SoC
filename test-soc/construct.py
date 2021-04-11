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

    # -------------------------------------------------------------------------
    # Supported tests
    # -------------------------------------------------------------------------

    test_names = [
        # CPU Tests
        #'apb_mux_test',
        #'hello_test',
        #'memory_test',
        #'dma_single_channel',
        #'default_slaves_test',
        #'interrupts_test',
        #'tlx_test',
        #'cgra_test',
        #'master_clock_test',
        'app_test',
        'harris_test',
        'app_test_two_images',
        'app_test_reconfig',
        'app_test_reconfig_pipeline',
        'app_test_2_kernels_1_cgra',
       # 'cascade_test',
        #'resnet_test',
        #'resnet_test_i4_o3',
        'demosaic_complex',
        'demosaic_complex_twice',
        #'demosaic_complex_harris',
        #'resnet_pond',

        # CXDT Tests
        'discovery',
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
        'ARM_IP_DIR': '/home/kkoul/aham3soc_armip',
        'AHA_IP_DIR': '/sim/kkoul/AhaM3SoC',
        'GATE_LEVEL_DIR': '/home/kkoul/gate_level_199',
        'GARNET_DIR': '/sim/kkoul/garnet',
        'TLX_FWD_DATA_LO_WIDTH': 16,
        'TLX_REV_DATA_LO_WIDTH': 45,
    }

    # -------------------------------------------------------------------------
    # Custom steps
    # -------------------------------------------------------------------------

    this_dir = os.path.dirname(os.path.abspath(__file__))

    garnet_rtl      	= Step(parameters['GARNET_DIR'] + '/mflowgen/common/rtl')
    compile_design  	= Step(this_dir + '/compile_design')
    compile_design_gls  = Step(this_dir + '/compile_design_gls')
    build_test      	= Step(this_dir + '/build_test')
    run_test        	= Step(this_dir + '/run_test')
    run_test_gls        = Step(this_dir + '/run_test_gls')
    verdict         	= Step(this_dir + '/verdict')
    test_gen         	= Step(this_dir + '/test_gen')
    ptpx 				= Step(this_dir + '/ptpx')

    # -------------------------------------------------------------------------
    # Parallelize test build and run
    # -------------------------------------------------------------------------

    test_count = len(test_names)
    build_steps = list(map((lambda _: build_test.clone()), range(test_count)))
    run_steps = list(map((lambda _: run_test.clone()), range(test_count)))
    run_gls_steps = list(map((lambda _: run_test_gls.clone()), range(test_count)))
    ptpx_steps = list(map((lambda _: ptpx.clone()), range(test_count)))
	

    for step, name in zip(build_steps, test_names):
        step.set_name('build_' + name)
    for step, name in zip(run_steps, test_names):
        step.set_name('run_' + name)
    for step, name in zip(run_gls_steps, test_names):
        step.set_name('run_gls_' + name)
    for step, name in zip(ptpx_steps, test_names):
        step.set_name('ptpx_' + name)

    # -------------------------------------------------------------------------
    # Input/output dependencies
    # -------------------------------------------------------------------------

    # 'compile_design' step produces a simulation executable and its accompanying collateral
    compile_design.extend_outputs(['xcelium.d'])
    compile_design.extend_inputs(['design.v'])
    compile_design_gls.extend_outputs(['simv'])
    compile_design_gls.extend_outputs(['simv.daidir'])

    # 'build_test' produces final images for both the CXDT and CPU
    for step in build_steps:
        step.extend_outputs(['CXDT.bin'])

    # 'run_tests' takes CXDT.bin, CPU.bin, and xcelium.d to produce a log
    for step, test in zip(run_steps, test_names):
        step.extend_inputs(['CXDT.bin', 'xcelium.d'])
        step.extend_outputs(['xrun_run_' + test + '.log'])

    # 'run_gls_tests' takes CXDT.bin, CPU.bin, and simv and simv.daidir to produce a log
    for step, test in zip(run_gls_steps, test_names):
        step.extend_inputs(['CXDT.bin', 'simv', 'simv.daidir'])
        step.extend_outputs(['reconfigure.saif'])
        step.extend_outputs(['run_1_kernel_plus_setup.saif'])

    # 'ptpx' takes saif to produce power reports
    for step, test in zip(run_gls_steps, test_names):
        step.extend_inputs(['run_1_kernel_plus_setup.saif'])

    # 'verdict' consumes the run logs
    run_logs = list(map((lambda test: 'xrun_run_' + test + '.log'), test_names))
    verdict.extend_inputs(run_logs)

    # -------------------------------------------------------------------------
    # Graph -- Add nodes
    # -------------------------------------------------------------------------

    g.add_step(garnet_rtl)
    g.add_step(compile_design)
    g.add_step(compile_design_gls)
    g.add_step(test_gen)

    for s in build_steps:
        g.add_step(s)

    for s in run_steps:
        g.add_step(s)

    for s in run_gls_steps:
        g.add_step(s)

    for s in ptpx_steps:
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

    for r, b in zip(run_gls_steps, build_steps):
        g.connect_by_name(b, r)
        g.connect_by_name(compile_design_gls, r)

    for p, r in zip(ptpx_steps, run_gls_steps):
        g.connect_by_name(r, p)

    # -------------------------------------------------------------------------
    # Set general parameters
    # -------------------------------------------------------------------------

    g.update_params(parameters)

    # -------------------------------------------------------------------------
    # Set node-specific parameters
    # -------------------------------------------------------------------------

    # Turn off power domain to improve the speed
    garnet_rtl.update_params({'PWR_AWARE': False})
    garnet_rtl.update_params({'array_width': parameters['array_width']})
    garnet_rtl.update_params({'array_height': parameters['array_height']})

    for step, test in zip(build_steps, test_names):
        step.update_params({'TEST_NAME': test})
    for step, test in zip(run_steps, test_names):
        step.update_params({'TEST_NAME': test})
    for step, test in zip(run_gls_steps, test_names):
        step.update_params({'TEST_NAME': test})
    for step, test in zip(ptpx_steps, test_names):
        step.update_params({'TEST_NAME': test})



    compile_design.update_params({'CGRA_RD_WS': 4})

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
        "assert 'Error' not in File('xrun_compile.log', enable_case_sensitive = True)",
        "assert File('outputs/xcelium.d')",
    ])

    return g


if __name__ == '__main__':
    g = construct()
