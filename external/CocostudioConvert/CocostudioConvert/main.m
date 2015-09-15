//
//  main.m
//  CocostudioConvert
//
//  Created by DannyHe on 3/30/15.
//  Copyright (c) 2015 BatCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

static NSString * plist_path;
static NSString * json_path;
static NSString * export_path;
static NSString * dic_path;

static NSMutableArray * plist_arrays;
static NSFileManager *myFileManager;
static NSString *extension_name;
static Boolean willDeleteNotFoundDisplayData = NO; //是否删除json中未找到图片的数据
void init_Plist()
{
    NSArray *directoryContents;
    directoryContents=[myFileManager contentsOfDirectoryAtPath:plist_path error:nil];
    
    NSString *file;
    for(file in directoryContents)
        
    {
        if(![file isEqualTo:@".DS_Store"]&&[[file pathExtension] isEqualToString:@"plist"])
        {
            NSString *temp_path =[NSString stringWithFormat:@"%@/%@",plist_path,file];
            printf("\n初始化Plist:%s\n",[temp_path UTF8String]);
            NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:temp_path];
            NSDictionary *frames = [dic objectForKey:@"frames"];
            NSDictionary *result_dic = [[NSDictionary alloc]initWithObjects:@[[[frames allKeys]copy],file] forKeys:@[@"png",@"file"]];
            [plist_arrays addObject:result_dic];
        }
    }
//    NSLog(@"%@",plist_arrays);
}

NSString * isPlistContainDisplayData(NSString * key)
{
    NSString *str = @"";
    for (NSDictionary *plist_dic in plist_arrays) {
        NSArray *pngs = [plist_dic objectForKey:@"png"];
        if([pngs containsObject:key])
        {
            return [plist_dic objectForKey:@"file"];
        }
        
    }
    return str;
}

void __json__handle(NSString *temp_path)
{
    
}

void __main__()
{
    NSArray *directoryContents;
    directoryContents=[myFileManager contentsOfDirectoryAtPath:json_path error:nil];
    
    NSString *file;
    for(file in directoryContents)
        
    {
        if(![file isEqualTo:@".DS_Store"]&&[[file pathExtension] isEqualToString:@"ExportJson"])
        {
            NSString *temp_path =[NSString stringWithFormat:@"%@/%@",json_path,file];
            printf("\n-->处理文件:%s\n",[temp_path UTF8String]);
            NSString *str = [[NSString alloc]initWithContentsOfFile:temp_path encoding:NSUTF8StringEncoding error:nil];
            NSData  *jsonData  =  [str  dataUsingEncoding : NSUTF8StringEncoding];
            NSDictionary  *dic  =  [[ [ CJSONDeserializer  deserializer ] deserializeAsDictionary:jsonData error:nil]mutableCopy];
            NSArray *armature_data = [dic objectForKey:@"armature_data"];
            NSMutableSet *config_file_path_array = [[NSMutableSet alloc]init];
            NSMutableSet *config_png_path = [[NSMutableSet alloc]init];
            
            for (NSDictionary *armature_data_it in armature_data) {
                NSNumber * version = [armature_data_it objectForKey:@"version"];
                if ([version intValue] > 1.6)
                {
                    printf("\n警告:暂时仅支持Cocostudio 1.6及其以下版本!\n");
                    continue;
                }
                NSArray * bone_data = [armature_data_it objectForKey:@"bone_data"];
                for (NSDictionary * bone_data_it in bone_data) {
                    NSArray *display_data = [bone_data_it objectForKey:@"display_data"];
                    NSMutableArray *final_display_data = [[NSMutableArray alloc]init];
                    for (NSDictionary * display_data_it in display_data) {
                        NSString *key = [display_data_it objectForKey:@"name"];
                        NSString *plist_name = isPlistContainDisplayData(key);
                        if (![plist_name isEqualTo:@""])
                        {
                            [config_file_path_array addObject:plist_name];
                            [config_png_path addObject:[NSString stringWithFormat:@"%@.%@",[plist_name stringByDeletingPathExtension],extension_name]];
                            [final_display_data addObject:display_data_it];
                        }
                        else if(willDeleteNotFoundDisplayData)
                        {
                            printf("\n警告::删除未找到的数据:%s\n",[key UTF8String]);
                        }
                    }
                    if(willDeleteNotFoundDisplayData)
                    {
                        [bone_data_it setValue:final_display_data forKey:@"display_data"];
                    }
                }
            }
            if([config_file_path_array count] == 0){
                printf("\n错误::\n%s中的未找到贴图文件！\n",[file UTF8String]);
            }
            else
            {
                [dic setValue:[config_file_path_array allObjects] forKey:@"config_file_path"];
                [dic setValue:[config_png_path allObjects] forKey:@"config_png_path"];
                NSData  *re_data = [[CJSONSerializer serializer] serializeDictionary:dic error:nil];
                NSString* json_result =  [[NSString alloc] initWithData:re_data encoding:NSUTF8StringEncoding];
                [json_result writeToFile:[NSString stringWithFormat:@"%@/%@",export_path,file] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
    }
}




int main(int argc, const char * argv[]) {
    if(argc<2)
    {
        printf("参数错误！\nCocostudioConvert dir_path [texture file extension]\n");
        printf("example:\nCocostudioConvert ~/Desktop\nCocostudioConvert ~/Desktop png\n");
        return 1;
    }
    if (argc > 2)
    {
        extension_name = [[NSString alloc]initWithUTF8String:argv[2]];
    }
    else
    {
        extension_name = @"png";
    }

    if (argc > 3)
    {
        willDeleteNotFoundDisplayData = [[[NSString alloc]initWithUTF8String:argv[3]] isEqualToString:@"true"];
    }
    myFileManager=[NSFileManager defaultManager];
    dic_path  = [[NSString alloc]initWithUTF8String:argv[1]];
    plist_path= [NSString stringWithFormat:@"%@/plist",dic_path];
    json_path= [NSString stringWithFormat:@"%@/json",dic_path];
    export_path= [NSString stringWithFormat:@"%@/export",dic_path];
    printf("环境变量:(保证有以下文件夹)\n");
    printf("---------------------------------------------------------\n");
    printf("dic_path:%s\n",[dic_path UTF8String]);
    printf("plist_path:%s\n",[plist_path UTF8String]);
    printf("json_path:%s\n",[json_path UTF8String]);
    printf("export_path:%s\n",[export_path UTF8String]);
    plist_arrays = [[NSMutableArray alloc]init];
    init_Plist();
    printf("\n-------------------------开始处理--------------------------------\n");
    __main__();
    printf("处理完成!\n");
  
    return 0;
}
