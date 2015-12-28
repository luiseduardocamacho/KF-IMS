@isTest public class CreateIIFromLineItemTest {
    
    public static testMethod void testCreateLineItem() 
    {
        Test.startTest();
        	Line_Item__c LI1 = LineItemHelper.CreateLineItems(false,false,false,'Computer');
        	Line_Item__c LITU = [Select Id, Name, Order_Complete__c FROM Line_Item__c WHERE Id = :LI1.Id];
        	LITU.Order_Complete__c = true;
        	update LITU;
        Test.stopTest();
        
        	Inventory_Item__c II = [Select Id, Name, Line_Item_Number__c, Line_Item_ID__c, Equipment_Class__c, Product_Name__c  
                                    FROM Inventory_Item__c WHERE Product_Name__c = :LI1.Product_Name__c LIMIT 1 ];
        
        	Line_Item__c LineItemUpdated = [Select Id, Inventory_Items_Created__c FROM Line_Item__c WHERE Id = :LI1.Id];
        
        	System.assertNotEquals(null, II);
        	System.assertEquals('TestAccount', II.Product_Name__c);
        	System.assertEquals(LITU.ID, II.Line_Item_ID__c);
        	System.assertEquals(LITU.Name, II.Line_Item_Number__c);
        	//Testing Line Item, Inventory Item update functionality
        	
        	//System.assertEquals((string)II.Name + ' - ' + II.Product_Name__c, LineItemUpdated.Inventory_Items_Created__c.replaceAll('<[^>]+>',' '));
        	System.assert(LineItemUpdated.Inventory_Items_Created__c.contains('a href='));
        	System.assert(LineItemUpdated.Inventory_Items_Created__c.contains(II.Name + ' - ' + II.Product_Name__c));
        	
    }
    
        public static testMethod void testItemReturned() 
    {
        Test.startTest();
        	Line_Item__c LI1 = LineItemHelper.CreateLineItems(false,true,false,'Computer');
        	Line_Item__c LITU = [Select Id, Order_Complete__c FROM Line_Item__c WHERE Id = :LI1.Id];
        	LITU.Order_Complete__c = true;
        	update LITU;
        Test.stopTest();
        
        	List <Inventory_Item__c> II = [Select Id, Equipment_Class__c, Product_Name__c  FROM Inventory_Item__c];
        	
        	System.assertEquals(0,II.Size());        	
    }
    
        public static testMethod void testUpdateWhenItemCreated() 
    {
        Test.startTest();
        	Line_Item__c LI1 = LineItemHelper.CreateLineItems(true,false,false,'Computer');
        	Line_Item__c LITU = [Select Id, Order_Complete__c FROM Line_Item__c WHERE Id = :LI1.Id];
        	LITU.Order_Complete__c = true;
        	update LITU;
        Test.stopTest();
			List <Inventory_Item__c> II = [Select Id, Equipment_Class__c, Product_Name__c  FROM Inventory_Item__c];
        	
        	System.assertEquals(0,II.Size());    	
    }
    
    public static testMethod void testBatchOrderComplete(){
       	
        LineItemHelper.CreateMultipleLineItems();
		      	 
        Test.startTest();            
        	List <Line_Item__c> LITU = new List <Line_Item__c>();
       		List <Line_Item__c> LIL = [Select Id FROM Line_Item__c];
        		For (Line_Item__c LI : LIL)
        		{
                    LI.Order_Complete__c = TRUE;
            		LITU.add(LI);
                    
       	 		}
       	 	Update LITU;
        Test.stopTest();
        
         	Integer Count = [Select COUNT() FROM Inventory_Item__c];
        	Integer CountComputers = [Select COUNT() FROM Inventory_Item__c Where Inventory_Item__c.RecordType.Name = 'Computer'];
        	
        	Contact contact = [Select Id, LastName from Contact where LastName = 'ContactTest' Limit 1];
        
        	List <Inventory_Item__c> inventoryItemList = [Select Id, RecordType.Name, Assigned_to__c From Inventory_Item__c where Assigned_to__c = :contact.id];
        	Inventory_Item__c inventoryItem = [Select Id, Status__C, Purchase_Date__c,Assigned_to__c, RecordType.Name, 
                                            Product_Name__c, Purchase_Price__c from Inventory_Item__c where Inventory_Item__c.Product_Name__c = 'Assigned Other Inventory 1' ];
        	
        	System.assertEquals('Assigned Other Inventory 1',inventoryItem.Product_Name__c);
        	System.assertEquals('In Use',inventoryItem.Status__c);
        	System.assertEquals(Date.today(),inventoryItem.Purchase_Date__c);
        	System.assertEquals(100, inventoryItemList.size());
        	System.assertEquals(200, Count);
        	System.assertEquals(60, CountComputers);

    }
    
    public static testMethod void testRecursiveWorking(){
        
        LineItemHelper.CreateMultipleLineItems();
        
        Test.startTest();
       		Recursive.setWorking();
        	List <Line_Item__c> LITU = new List <Line_Item__c>();
       		List <Line_Item__c> LIL = [Select Id FROM Line_Item__c];
        		For (Line_Item__c LI : LIL)
        		{
                    LI.Order_Complete__c = TRUE;
            		LITU.add(LI);
       	 		}
       	 	Update LITU;
        Test.stopTest();
        
            
    
    		Integer Count = [Select COUNT() FROM Inventory_Item__c];
        	Integer CountComputers = [Select COUNT() FROM Inventory_Item__c Where Inventory_Item__c.RecordType.Name = 'Computer'];
        	System.assertEquals(0, Count);
        	System.assertEquals(0, CountComputers);
    }
    
        public static testMethod void testRecursiveNotWorking(){
        
        LineItemHelper.CreateMultipleLineItems();
        
        Test.startTest();
       		Recursive.setClosed();
        	List <Line_Item__c> LITU = new List <Line_Item__c>();
       		List <Line_Item__c> LIL = [Select Id FROM Line_Item__c];
        		For (Line_Item__c LI : LIL)
        		{
                    LI.Order_Complete__c = TRUE;
            		LITU.add(LI);
       	 		}
       	 	Update LITU;
        Test.stopTest();
        
            
    
    		Integer Count = [Select COUNT() FROM Inventory_Item__c];
        	Integer CountComputers = [Select COUNT() FROM Inventory_Item__c Where Inventory_Item__c.RecordType.Name = 'Computer'];
        	System.assertEquals(200, Count);
        	System.assertEquals(60, CountComputers);
    }
    
    public static testMethod void testMultipleInventoryItemsFromSingleLineItem(){
        
        test.startTest();
        	Line_Item__c LI1 = LineItemHelper.CreateLineItems(false,false,false,'Computer');
        	Line_Item__c LITU = [Select Id, Name, Quantity__c, Order_Complete__c FROM Line_Item__c WHERE Id = :LI1.Id];
        	LITU.Quantity__c = 3;
        	LITU.Order_Complete__c = true;
        	update LITU;
        test.stopTest();
        
        Inventory_Item__c II = [Select Id, Name, Line_Item_Number__c, Line_Item_ID__c, Equipment_Class__c, Product_Name__c  
                                    FROM Inventory_Item__c WHERE Product_Name__c = :LI1.Product_Name__c LIMIT 1 ];
        
        Line_Item__c LineItemUpdated = [Select Id, Inventory_Items_Created__c FROM Line_Item__c WHERE Id = :LI1.Id];
        
        System.assert(LineItemUpdated.Inventory_Items_Created__c.contains('a href='));
        System.assert(LineItemUpdated.Inventory_Items_Created__c.contains(II.Name + ' - ' + II.Product_Name__c));
        System.assert(LineItemUpdated.Inventory_Items_Created__c.contains('<br><br>'));
        
    }
    


}