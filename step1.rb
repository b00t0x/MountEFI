require 'json'
require 'pp'

targets = Hash.new{ |h,k| h[k] = [] }

data = JSON(`diskutil list -plist | plutil -convert json -o - -`)
data['AllDisksAndPartitions'].each do |disk|
    next unless disk['Partitions']
    if disk['Partitions'].size == 0
        # apfs
        next unless disk['APFSVolumes']
        # get parrent device label
        /(?<label>disk\d+)s/ =~ disk['APFSPhysicalStores'].first['DeviceIdentifier']
        # get apfs volume name
        targets[label] += disk['APFSVolumes'].map{ |vol| vol['VolumeName'] }.select{ |name| name !~ /^(.+- Data|Preboot|Recovery|VM|Update)$/ }
    else
        # physical disk
        next unless disk['Partitions'].first['Content'] == 'EFI'
        label = disk['DeviceIdentifier']
        # get partition name
        targets[label] += disk['Partitions'][1..-1].map{ |part| part['VolumeName'] }
    end
end
targets.each do |label, target|
    puts "#{label}: #{target.compact.uniq.join(', ')}"
end
