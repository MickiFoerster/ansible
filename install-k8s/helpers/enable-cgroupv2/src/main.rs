use std::fs::OpenOptions;
use std::io::BufRead;
use std::io::Seek;
use std::io::SeekFrom;
use std::io::Write;
use std::path::PathBuf;

fn main() -> std::io::Result<()> {
    let path = PathBuf::from("/etc/default/grub");
    let file = std::fs::File::open(&path).expect("Could not open file");

    let mut new_content: Vec<String> = vec![];
    for line in std::io::BufReader::new(&file).lines().flatten() {
        match line.find("GRUB_CMDLINE_LINUX=\"") {
            Some(0) => {
                let len = "GRUB_CMDLINE_LINUX=\"".to_string().len();
                let new_line = format!(
                    "GRUB_CMDLINE_LINUX=\"systemd.unified_cgroup_hierarchy=1 {}",
                    &line[len..]
                );
                new_content.push(new_line);
            }
            Some(_) => panic!("Not expected non-zero index for finding string pattern"),
            None => {
                new_content.push(line);
            }
        }
    }

    let mut file = OpenOptions::new()
        .read(true)
        .write(true)
        .open(path)
        .expect("Could not open file");
    match file.seek(SeekFrom::Start(0)) {
        Ok(i) => println!("File seeked to offset {i} from start"),
        Err(e) => eprintln!("{e}"),
    }
    for mut line in new_content {
        line += "\n";
        file.write_all(line.as_bytes())?;
    }

    Ok(())
}
