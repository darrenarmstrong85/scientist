if [ -f ~/.bashrc_old ]; then
	source ~/.bashrc_old
fi

for file in ~/.bashrc.d/*; do
	if [ -f "$file" ]; then
		source "$file"
	fi
done
