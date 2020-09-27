use inc::Module::Install;

# Define metadata
name 'Data-3D-Grids';
all_from 'lib/Data/3D/Grids';

# Specific dependencies
requires 'Moo';
requires 'Scalar::Util' => '1.49';
requires 'GD';
requires 'Sql::Abstract';

no_index 'directory' => 'demos';

# install_script 'myscript';

WriteAll;
