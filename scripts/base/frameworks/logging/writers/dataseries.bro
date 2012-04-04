##! Interface for the dataseries log writer.

module LogDataSeries;

export {
	## Compression to use with the DS output file.  Options are:
	##
	## 'none' -- No compression.
	## 'lzf' -- LZF compression.  Very quick, but leads to larger output files.
	## 'lzo' -- LZO compression.  Very fast decompression times.
	## 'gz' -- GZIP compression.  Slower than LZF, but also produces smaller output.
	## 'bz2' -- BZIP2 compression.  Slower than GZIP, but also produces smaller output.
	const ds_compression = "lzf" &redef;

	## The extent buffer size.
	## Larger values here lead to better compression and more efficient writes, but
	## also increases the lag between the time events are received and the time they
	## are actually written to disk.
	const ds_extent_size = 65536 &redef;

	## Should we dump the XML schema we use for this ds file to disk?
	## If yes, the XML schema shares the name of the logfile, but has
	## an XML ending.
	const ds_dump_schema = T &redef;

	## How many threads should DataSeries spawn to perform compression?
	## Note that this dictates the number of threads per log stream.  If
	## you're using a lot of streams, you may want to keep this number
	## relatively small.
	##
	## Default value is 1, which will spawn one thread / core / stream.
	## 
	## MAX is 128, MIN is 1.
	const ds_num_threads = 1 &redef;

	## Should time be stored as an integer or a double?
	## Storing time as a double leads to possible precision issues and
	## could (significantly) increase the size of the resulting DS log.
	## That said, timestamps stored in double form are more consistent
	## with the rest of Bro and are more easily readable / understandable
	## when working with the raw DataSeries format.
	## 
	## Double timestamps are used by default.
	const ds_use_integer = F &redef;
}

# Default function to postprocess a rotated DataSeries log file. It moves the
# rotated file to a new name that includes a timestamp with the opening time, and
# then runs the writer's default postprocessor command on it.
function default_rotation_postprocessor_func(info: Log::RotationInfo) : bool
	{
	# Move file to name including both opening and closing time.
	local dst = fmt("%s.%s.ds", info$path,
			strftime(Log::default_rotation_date_format, info$open));

	system(fmt("/bin/mv %s %s", info$fname, dst));

	# Run default postprocessor.
	return Log::run_rotation_postprocessor_cmd(info, dst);
	}

redef Log::default_rotation_postprocessors += { [Log::WRITER_DATASERIES] = default_rotation_postprocessor_func };
