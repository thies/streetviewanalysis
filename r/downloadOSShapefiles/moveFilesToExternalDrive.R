done <- list.files("~/Downloads/")
done <- done[grepl('Download_', done)]
done <- done[! grepl('.zip.txt', done)]



for(f in done){
  print(f)
  mv <- paste("mv /home/thies/Downloads/", f, " ","/home/thies/Downloads/osdata/",f, sep="")
  tou <- paste("touch /home/thies/Downloads/", f,".txt", sep="")
  system(mv)
  system(tou)
}