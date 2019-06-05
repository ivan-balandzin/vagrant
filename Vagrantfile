Vagrant.configure("2") do |config|
	box = "sbeliakou/centos"
	N = 2 
	M = 1
	
	(1..N).each do |i|
		config.vm.define "nginx.backend#{i}" do |node|
			node.vm.box = "#{box}"
			node.vm.hostname = "nginx.backend#{i}"
			node.vm.network "private_network", ip: "192.168.56.#{i+1}"
			node.vm.provision "shell", path: "prov_nginx.sh", :args => "#{i}";
		end	
	end

	(1..M).each do |i|
		config.vm.define "nginx.balancer#{i}" do |node|
			node.vm.box = "#{box}"
			node.vm.hostname = "nginx.balancer#{i}"
			node.vm.network "private_network", ip: "192.168.56.#{i+100}"
			node.vm.provision "shell", path: "prov_nginx.sh", :args => "#{N}";
		end	
	end
end

